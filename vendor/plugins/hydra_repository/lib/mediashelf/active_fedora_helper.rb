# Stanford SolrHelper is a controller layer mixin. It is in the controller scope: request params, session etc.
# 
# NOTE: Be careful when creating variables here as they may be overriding something that already exists.
# The ActionController docs: http://api.rubyonrails.org/classes/ActionController/Base.html
#
# Override these methods in your own controller for customizations:
# 
# class HomeController < ActionController::Base
#   
#   include Stanford::SolrHelper
#   
#   def solr_search_params
#     super.merge :per_page=>10
#   end
#   
# end
#
module MediaShelf
  module ActiveFedoraHelper

    def retrieve_af_model(class_name, opts={})
      logger.error("class_name: #{class_name}")
      if !class_name.nil?
        klass = Module.const_get(class_name.camelcase)
        logger.error("class_name: #{klass}")
      else
        klass = nil
      end
      logger.error("klass: #{klass}")
      #klass.included_modules.include?(ActiveFedora::Model)
      if klass.is_a?(Class) && klass.superclass == ActiveFedora::Base
        return klass
      else
        logger.error("klass is not a class or its superclass is: #{klass.superclass}")
        return opts.fetch(:default, false)
      end
    rescue NameError
        logger.error("looks like name error")
        return false
    end

    def load_af_instance_from_solr(doc)
      pid = doc[:id] ? doc[:id] : doc[:id.to_s]
      pid ? ActiveFedora::Base.load_instance_from_solr(pid,doc) : nil
    end

    def add_named_relationship(asset, relationship_name, target_pid)
    if asset.nil?
      raise "Assest Missing"
    else
      if asset.respond_to?(:add_named_relationship)
        if asset.is_named_relationship?(relationship_name,true)
          #check if :type is defined for this relationship, if so instantiate with that type
          if named_relationships_desc[:self][name].has_key?(:type)
            klass = class_from_name(named_relationships_desc[:self][name][:type])
            unless klass.nil?
              @object = klass.load_instance(target_pid)
              raise "Unable to find fedora object with pid #{target_pid}" if @object.nil?
              (assert_kind_of_model 'object', @object, klass)
            end
            asset.add_named_relationship(relationship_name,@object)
          else
            @object = ActiveFedora::Base.load_instance(target_pid)
            raise "Unable to find fedora object with pid #{target_pid} t" if @object.nil?
            asset.add_named_relationship(relationship_name,@object)
          end
        	asset.save
        else
          raise "outbound relationship: #{relationship_name} does not exist for content model: #{asset.class}"
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

=begin def load_instance(content_model, pid)
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
=end

    private
  
    def require_fedora
      Fedora::Repository.register(ActiveFedora.fedora_config[:url],  session[:user])
      return true
    end
  
    def require_solr
      ActiveFedora::SolrService.register(ActiveFedora.solr_config[:url])
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
end
