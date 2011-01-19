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
      if !class_name.nil?
        klass = Module.const_get(class_name.camelcase)
      else
        klass = nil
      end
      #klass.included_modules.include?(ActiveFedora::Model)  
      if klass.is_a?(Class) && klass.superclass == ActiveFedora::Base
        return klass
      else
        return opts.fetch(:default, false)
      end
      rescue NameError
        return false
    end

    def load_af_instance_from_solr(doc)
      pid = doc[:id] ? doc[:id] : doc[:id.to_s]
      if pid
        if doc[:active_fedora_model_s]
          return doc[:active_fedora_model_s].first.constantize.load_instance_from_solr(doc[:id])  
        elsif doc[:has_model_s] || doc["has_model_s"]
          doc[:has_model_s] ? model = doc[:has_model_s].first.gsub("info:fedora/afmodel:","") :  model = doc["has_model_s"].first.gsub("info:fedora/afmodel:","") 
          return model.constantize.load_instance_from_solr(doc[:id])  
        else
          return ActiveFedora::Base.load_instance_from_solr(pid)
        end
      else
        return nil
      end
    end

    def add_named_relationship(asset, relationship_name, target_pid)
    if asset.nil?
      raise "Assest Missing"
    else
      if asset.respond_to?(:add_named_relationship)
        if asset.is_named_relationship?(relationship_name,true)
          #check if :type is defined for this relationship, if so instantiate with that type
          if asset.named_relationship_type(relationship_name).nil?
             @object = ActiveFedora::Base.load_instance(target_pid)
          else
            @object = (asset.named_relationship_type(relationship_name)).load_instance(target_pid)                        
          end
          if @object.nil?
            raise "Unable to find #{relationship_name} object with pid #{target_pid}"
          else
            asset.add_named_relationship(relationship_name,@object)
            asset.save
          end        	
        else
          raise "outbound relationship: #{relationship_name} does not exist for content model: #{asset.class}"
        end
      else
        raise "Content model: #{asset.class} does not implement add_named_relationship"
      end
    end
  end

  def remove_named_relationship(asset, relationship_name, target_pid)
    if asset.nil?
      raise "asset missing"
    else
      if asset.respond_to?(:remove_named_relationship)
        if asset.is_named_relationship?(relationship_name,true)
          #check if :type is defined for this relationship, if so instantiate with that type
          if asset.named_relationship_type(relationship_name).nil?
             @object = ActiveFedora::Base.load_instance(target_pid)
          else
            @object = (asset.named_relationship_type(relationship_name)).load_instance(target_pid)
          end
          if @object.nil?
            raise "Unable to find #{relationship_name} object with pid #{target_pid}"
          else
        	  asset.remove_named_relationship(relationship_name,@object)
        	  asset.save
          end
        else
          raise "Outbound named relationship #{relationship_name} does not exist for Content model: #{asset.class}"
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
