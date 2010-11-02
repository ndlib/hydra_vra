class LotsController < ApplicationController
  
  include Hydra::AssetsControllerHelper
  include Hydra::FileAssetsHelper  
  include Hydra::RepositoryController  
  include MediaShelf::ActiveFedoraHelper
  include Blacklight::SolrHelper
  
  before_filter :require_fedora
  before_filter :require_solr, :only=>[:index, :create, :show, :destroy]
  
  
  def index
    if params[:layout] == "false"
      # action = "index_embedded"
      layout = false
    end
    render :action=>params[:action], :layout=>layout
  end
  
  def new
    render :partial=>"new", :layout=>false
  end
  
  def create
    attributes = params
    unless attributes.has_key?(:label)
      attributes[:label] = "Lot"
    end
    lot_pid=  generate_pid(params[:key])
    if (!lot_available(lot_pid))
      attributes["pid"]=  lot_pid
      attributes.merge!({:new_object=>true})
      if attributes.has_key?("pid")
        attributes.merge!({:pid=>attributes["pid"]})
        attributes[:pid] = attributes["pid"]
      end
      attributes[:pid] = attributes[:pid]["0"] if attributes.has_key?(:pid) && attributes[:pid].is_a?(Hash) && attributes[:pid].has_key?("0")
      @lot = create_instance("Lot", attributes)
      @lot.update_indexed_attributes(attributes)
      @lot.save
      apply_depositor_metadata(@lot)
      logger.debug "Created Lot with pid #{@lot.pid}."
    else
      logger.debug "Lot is create already. So load the obj"
      @lot=load_instance("lot",lot_pid)
    end
    add_named_relationship(params[:target_content_type], params[:target_pid])
    render :nothing => true
  end

  def lot_available(pid)
    content_model_type = nil
    args = {:id=> pid}
    opts = {}
    content_model="Lot"
    object = content_model.split('::').inject(Kernel) {|scope, const_name|
    content_model_type = scope.const_get(const_name)}
    unless content_model_type.nil?
      logger.debug "#{content_model_type} methods: #{content_model_type.class.methods.sort.inspect}"
      raise "Content model Lot does not implement find_by_fields_by_solr" unless content_model_type.respond_to?(:find_by_fields_by_solr)
      results = content_model_type.find_by_fields_by_solr(args,opts)
      if results.nil? || results.hits.nil? || results.hits.empty? || results.hits.first[SOLR_DOCUMENT_ID].nil?
        logger.error("Result is empty need to create new obj")
        return false
      else
        logger.error("result from solr: #{results.inspect}")
        return true
      end
    end
    return false
  end

  def create_instance(content_model,attributes={})
    content_model.split('::').inject(Kernel) {|scope, const_name|
    scope.const_get(const_name)}.new(attributes)
  end

  def add_named_relationship(target_content_type, target_pid)
    if @lot.nil?
      raise "Lot object with content model"
    else
      if @lot.respond_to?(:add_named_relationship)
        if @lot.is_named_relationship?(target_content_type,true)
          #check if :type is defined for this relationship, if so instantiate with that type
          unless @lot.named_relationship_type(target_content_type).nil?
          	@object = load_instance(@lot.named_relationship_type(target_content_type).to_s,target_pid)
          end
          #check object for added relationship
          if @object.nil?
            raise "Unable to find fedora object with pid #{target_pid} to add to pid: #{@lot.pid} as #{target_content_type}"
          else
        	@lot.add_named_relationship(target_content_type,@object)
        	@lot.save
          end
        else
          raise "outbound relationship: #{target_content_type} does not exist for content model: #{@lot.class}"
        end
      else
        raise "Content model: #{@lot.class} does not implement add_named_relationship"
      end
    end
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

  def generate_pid(key)
    #namespace="ARCH-SEASIDE"
    #content_model="Lot"
    #pid=namespace << ":" << content_model << key
    pid="changme:61"
    logger.error ("Pid of the Lot to add relationship: #{pid}")
    return pid
  end
  # Common destroy method for all AssetsControllers 
  def destroy
    # The correct implementation, with garbage collection:
    # if params.has_key?(:container_id)
    #   container = ActiveFedora::Base.load_instance(params[:container_id]) 
    #   container.file_objects_remove(params[:id])
    #   FileAsset.garbage_collect(params[:id])
    # else
    
    # The dirty implementation (leaves relationship in container object, deletes regardless of whether the file object has other containers)
    ActiveFedora::Base.load_instance(params[:id]).delete 
    render :text => "Deleted #{params[:id]} from #{params[:container_id]}."
  end
  
  
  def show
    @file_asset = FileAsset.find(params[:id])
    if (@file_asset.nil?)
      logger.warn("No such file asset: " + params[:id])
      flash[:notice]= "No such file asset."
      redirect_to(:action => 'index', :q => nil , :f => nil)
    else
      # get array of parent (container) objects for this FileAsset
      @id_array = @file_asset.containers(:response_format => :id_array)
      @downloadable = false
      # A FileAsset is downloadable iff the user has read or higher access to a parent
      @id_array.each do |pid|
        @response, @document = get_solr_response_for_doc_id(pid)
        if reader?
          @downloadable = true
          break
        end
      end

      if @downloadable
        if @file_asset.datastreams_in_memory.include?("DS1")
          send_datastream @file_asset.datastreams_in_memory["DS1"]
        end
      else
        flash[:notice]= "You do not have sufficient access privileges to download this document, which has been marked private."
        redirect_to(:action => 'index', :q => nil , :f => nil)
      end
    end
  end
end
