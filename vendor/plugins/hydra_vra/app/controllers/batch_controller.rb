require "active_fedora"
class BatchController < ApplicationController
  #before_filter :require_login, :require_fedora, :require_solr, :setup
  before_filter :require_login
  before_filter :setup, :except => [:create]
  before_filter :application_administrator, :except => [:index, :show, :find, :datastreams, :named_datastreams, :relationships, :named_relationships, :describe]
  #before_filter :setup

  def index
  end
  
  def create
    check_required_params([:content_model])
    @content_model = params[:content_model]
    attributes = params
    unless attributes.has_key?(:label) 
      attributes[:label] = @content_model
    end
    attributes.merge!({:new_object=>true})
    if attributes.has_key?("pid")
      attributes.merge!({:pid=>attributes["pid"]})
      attributes[:pid] = attributes["pid"] 
      #attributes.delete("pid")
      #puts "#{attributes.inspect}"
    end
    attributes[:pid] = attributes[:pid]["0"] if attributes.has_key?(:pid) && attributes[:pid].is_a?(Hash) && attributes[:pid].has_key?("0")
    #puts "#{attributes.inspect}"
    @target = create_instance(@content_model,attributes)
    #attributes = unescape_keys(attributes)
    @target.update_indexed_attributes(attributes)
    @target.save
    #response = attributes.keys.map{|x| escape_keys({x=>attributes[x].values})}
    #logger.debug("returning #{response.inspect}") 
    #reload_objects
    render :json => @target.fields
  end

  def update
    check_required_params([:content_model,:pid])
  	attributes = params
  	#attributes = unescape_keys(attributes)
  	@target.update_indexed_attributes(attributes)
  	#response = attributes.keys.map{|x| escape_keys({x=>attributes[x].values})}
    #logger.debug("returning #{response.inspect}")
  	@target.save
  	#reload_objects
  	render :json => @target.fields
  end
  
  #This will return all objects that match the content model and query values passed in
  #within a :query parameter that should be a hash.  For example:
  #
  # query[title]=INQ would only return objects with title INQ
  #
  # You may also pass in options in the opts parameter as a hash like opts[sort]=id desc
  #
  # options include:
  # 
  #   :sort             => a comma separated list "[field_name] [asc|desc]", 
  #   :default_field, :rows, :filter_queries, :debug_query,
  #   :explain_other, :facets, :highlighting, :mlt,
  #   :operator         => :or / :and
  #   :start            => defaults to 0
  #   :field_list       => array, defaults to ["*", "score"]
  #
  def find
    check_required_params([:content_model])
    content_model_type = nil
    begin
      #use reflection to instantiate object
      object = @content_model.split('::').inject(Kernel) {|scope, const_name|
      content_model_type = scope.const_get(const_name)} 
    rescue
      raise "Content model #{@content_model} not found"
    end  
    unless content_model_type.nil?
      raise "Content model #{@content_model} does not implement find_by_fields_by_solr" unless content_model_type.respond_to?(:find_by_fields_by_solr)
      args = {}
      if params.has_key?(:query)
        unless params[:query].is_a?(Hash)
          raise "query parameter must be a hash"
        else
          args.merge!(params[:query])
        end
      end
      
      opts = {}
      if params.has_key?(:opts)
        unless params[:opts].is_a?(Hash)
          raise "opts parameter must be a hash"
        else
          opts = params[:opts]
        end
      end
      
      #if sort present update to format find_by_fields_by_solr expects
      if opts.include?(:sort)
        sort_array = []
        sort_fields = opts[:sort].split(",")
        sort_fields.each do |sort|
          sort_field_array = sort.split(" ")
          sort_field = sort_field_array.first
          sort_direction = :ascending
          if sort_field_array.size > 1 && sort_field_array[1].to_s =~ /^desc/
            sort_direction = :descending 
          end
          sort_array.push({sort_field=>sort_direction})  
        end
        opts[:sort] = sort_array
      end
       
      results = content_model_type.find_by_fields_by_solr(args,opts)
      unless results.nil? || results.hits.nil? || results.hits.empty? || results.hits.first[SOLR_DOCUMENT_ID].nil?
        objects = ActiveFedora::SolrService.reify_solr_results(results)
        field_arrays = []
        objects.each do |object|
          field_arrays.push(object.fields)
        end
      end
      render :json => field_arrays
    else
      raise "Content model #{@content_model} not found"
    end
  end

  def show
    check_required_params([:content_model,:pid])
  	render :json => @target.fields
  end
  
  def add_named_relationship
    check_required_params([:content_model,:pid,:name,:object_pid])
    name = params[:name]
    if @target.nil?
      raise "Unable to find fedora object with content model: #{@content_model} and pid: #{@pid}"
    else
      if @target.respond_to?(:add_named_relationship)
        if @target.is_named_relationship?(name,true)
          #check if :type is defined for this relationship, if so instantiate with that type
          unless @target.named_relationship_type(name).nil?
          	@object = load_instance(@target.named_relationship_type(name).to_s,@object_pid)
          end
          #check object for added relationship
          if @object.nil?
            raise "Unable to find fedora object with pid #{@object_pid} to add to pid: #{@pid} as #{@name}"
          else
        	@target.add_named_relationship(name,@object)
        	@target.save
          end
        else
          raise "outbound relationship: #{name} does not exist for content model: #{@content_model}"
        end
      else
        raise "Content model: #{@content_model} does not implement add_named_relationship"
      end
    end
    #reload_objects
    render :json => @target.named_relationships
  end
  
  def remove_named_relationship
    check_required_params([:content_model,:pid,:name,:object_pid])
    name = params[:name]
    if @target.nil? && !name.nil?
      return false #maybe throw exception instead
    else	
      if @target.respond_to?(:remove_named_relationship)
        if @target.is_named_relationship?(name,true)
          #check object for added relationship
          #check if :type is defined for this relationship, if so instantiate with that type
          unless @target.named_relationship_type(name).nil?
            @object = load_instance(@target.named_relationship_type(name).to_s,@object_pid)
          end
          if @object.nil?
            raise "Fedora object not found for content model #{@target.named_relationship_type(name).to_s} and pid #{@object_pid}"
          else
        	@target.remove_named_relationship(name,@object)
        	@target.save
          end
        else
          raise "Outbound named relationship #{name} does not exist for Content model: #{@content_model}"
        end
      else
        raise "Content model: #{@content_model} does not implement remove_named_relationship"
      end
    end
    #reload_objects
    render :json => @target.named_relationships
  end
  
  def add_named_datastream
    check_required_params([:content_model,:pid,:name,:file])
  	name = params[:name]
  	attributes = params
  	f = params[:file]
  	 
  	raise "You must submit an actual file for parameter file" unless f.kind_of?(File)||f.kind_of?(Tempfile)
  	 
    if @target.respond_to?(:add_named_datastream)
      dsid = @target.add_named_datastream(name,attributes)
      @target.save
      #reload_objects
      render :json => @target.datastreams_attributes[dsid]
    else
     raise "Fedora object #{@pid} content model #{@content_model} does not implement add_named_datastream"
    end
  end
  
  def update_named_datastream
    check_required_params([:content_model,:pid,:name,:file,:dsid])
    name = params[:name]
  	attributes = params
  	f = params[:file]
  	dsid = params[:dsid]
  	 
  	raise "You must submit an actual file for parameter file" unless f.kind_of?(File)||f.kind_of?(Tempfile)
  	 
    if @target.respond_to?(:update_named_datastream)
      @target.update_named_datastream(name,attributes)
      @target.save
      #reload_objects
      render :json => @target.datastreams_attributes[dsid]
    else
      raise "Fedora object #{@pid} content model #{@content_model} does not implement update_named_datastream"
    end
  end
  
  def datastreams
    check_required_params([:content_model,:pid])
    dsid = params[:dsid]
    unless dsid.nil?
	    #return actual stream
      ds = @target.datastreams[dsid]
       print "ds #{ds.inspect}"
      unless ds.nil?
        print "render File"
        send_data(ds.content, :type=> ds.attributes["mimeType"], :filename=> ds.label, :disposition=> 'inline')
	    else
	      raise "Datastream dsid #{dsid} not found for content model #{@target.class.to_s} and pid #{@target.pid}"
	    end
	  else
	    render :json => @target.datastreams_attributes
    end
  end

  def named_datastreams
    check_required_params([:content_model,:pid])
    name = params[:name]
    unless name.nil?
      #return metadata
      raise "Named datastream #{name} undefined for content model #{@content_model}" unless @target.is_named_datastream?(name)
      ds = @target.send("#{name}")
      attr = {}
      attr = ds.attributes unless ds.nil?
      render :json => attr
    else
      #return metadata
  	  render :json => @target.named_datastreams_attributes
  	end
  end
  
  def relationships
    check_required_params([:content_model,:pid])
    render :json => @target.relationships
  end
  
  def named_relationships
    check_required_params([:content_model,:pid])
     name = params[:name]
     unless name.nil?
       render :json => @target.named_relationship(name)
     else
       render :json => @target.named_relationships(false)
     end
  end

  def describe
     show
  end

  def destroy
    check_required_params([:content_model,:pid]) 
    render :json => @target.delete
  end
 
  private
  #underscores are escaped w/ + signs, which are unescaped by rails to spaces
  def unescape_keys(attrs)
    h=Hash.new
    attrs.each do |k,v|
      h[k.gsub(/ /, '_')]=v

    end
    h
  end
  def escape_keys(attrs)
    h=Hash.new
    attrs.each do |k,v|
      h[k.gsub(/_/, '+')]=v

    end
    h
  end

  def setup
    params[:pid] = params[:id] unless params.has_key?(:pid)
    @pid = params[:pid]
    @content_model = params[:content_model]
    @object_pid = params[:object_pid]
    
    #if id defined and content model defined call load_instance
    if @content_model.nil?
      raise "content_model parameter is required"
    elsif !@pid.nil?
      @target = load_instance(@content_model, @pid)
    end
    return true
  end
  
  def reload_objects
  	setup
  end

  def create_instance(content_model,attributes={})
    content_model.split('::').inject(Kernel) {|scope, const_name| 
    scope.const_get(const_name)}.new(attributes)
  end

  def load_instance(content_model, pid)
    begin
      #use reflection to instantiate object
      object = content_model.split('::').inject(Kernel) {|scope, const_name| 
      scope.const_get(const_name)}.load_instance(pid)
    rescue
      raise "Fedora Object not found for content model #{content_model} and pid #{pid}"
    end  
    
    #check that has model matches class
    object.assert_kind_of_model('Fedora Object', object, object.class)
    return object
  end

  def check_required_params(required_params)
    not_found = ""
    if required_params.respond_to?(:each)
      required_params.each do |param|
        not_found = not_found.concat("#{param} parameter is required\n") unless params.has_key?(param)
      end
    end
    raise not_found if not_found.length > 0
  end
  
  def fetch_url(url)
    r = Net::HTTP.get_response( URI.parse( url ) )
    if r.is_a? Net::HTTPSuccess
      r.body
    else
      nil
    end
  end
end
