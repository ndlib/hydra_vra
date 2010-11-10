require "om"
module Hydra::AssetsControllerHelper
  
  def apply_depositor_metadata(asset)
    if asset.respond_to?(:apply_depositor_metadata) && current_user.respond_to?(:login)
      asset.apply_depositor_metadata(current_user.login)
    end
  end

  def set_collection_type(asset, collection)
    if asset.respond_to?(:set_collection_type)
      asset.set_collection_type(collection)
    end
  end
  
  # 
  # parses your params hash, massaging them into an appropriate set of params and opts to pass into ActiveFedora::Base.update_indexed_attributes
  #
  def prep_updater_method_args(params)
    args = {:params=>{}, :opts=>{}}
    
    params["asset"].each_pair do |datastream_name,fields|
      
      args[:opts][:datastreams] = datastream_name
      
      # TEMPORARY HACK: special case for supporting textile 
      if params["field_id"]=="abstract_0" 
        params[:field_selectors] = {"descMetadata" => {"abstract" => [:abstract]}}
      end
      
      if params.fetch("field_selectors",false) && params["field_selectors"].fetch(datastream_name, false)
        # If there is an entry in field_selectors for the datastream (implying a nokogiri datastream), retrieve the field_selector for this field.
        # if no field selector, exists, use the field name
        fields.each_pair do |field_name,field_values|
          parent_select = OM.destringify( params["field_selectors"][datastream_name].fetch(field_name, field_name) )
          args[:params][parent_select] = field_values       
        end        
      else
        args[:params] = unescape_keys(params[:asset][datastream_name])
      end
    end
    
    return args
     
  end

  def add_named_relationship(asset, target_content_type, target_pid)
    if asset.nil?
      raise "Assest Missing"
    else
      if asset.respond_to?(:add_named_relationship)
        if asset.is_named_relationship?(target_content_type,true)
          #check if :type is defined for this relationship, if so instantiate with that type
          unless asset.named_relationship_type(target_content_type).nil?
          	@object = load_instance(asset.named_relationship_type(target_content_type).to_s,target_pid)
          end
          #check object for added relationship
          if @object.nil?
            raise "Unable to find fedora object with pid #{target_pid} to add to pid: #{@lot.pid} as #{target_content_type}"
          else
        	asset.add_named_relationship(target_content_type,@object)
        	asset.save
          end
        else
          raise "outbound relationship: #{target_content_type} does not exist for content model: #{asset.class}"
        end
      else
        raise "Content model: #{asset.class} does not implement add_named_relationship"
      end
    end
  end

  def remove_named_relationship(asset, target_content_type, target_pid)
    if asset.nil?
      raise "asset missing"
    else
      if asset.respond_to?(:remove_named_relationship)
        if asset.is_named_relationship?(target_content_type,true)
          #check object for added relationship
          #check if :type is defined for this relationship, if so instantiate with that type
          unless asset.named_relationship_type(target_content_type).nil?
            @object = load_instance(@lot.named_relationship_type(target_content_type).to_s,target_pid)
          end
          if @object.nil?
            raise "Fedora object not found for content model #{@lot.named_relationship_type(target_content_type).to_s} and pid #{target_pid}"
          else
        	asset.remove_named_relationship(target_content_type,@object)
        	asset.save
          end
        else
          raise "Outbound named relationship #{target_content_type} does not exist for Content model: #{asset.class}"
        end
      else
        raise "Content model: #{asset.class} does not implement remove_named_relationship"
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


  # moved destringify into OM gem. 
  # ie.  OM.destringify( params )
  # Note: OM now handles destringifying params internally.  You probably don't have to do it!
  
  private
    
  def send_datastream(datastream)
    send_data datastream.content, :filename=>datastream.label, :type=>datastream.attributes["mimeType"]
  end
  
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
  
end