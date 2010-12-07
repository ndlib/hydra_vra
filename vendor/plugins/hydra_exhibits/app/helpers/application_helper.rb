require "#{RAILS_ROOT}/vendor/plugins/hydra_repository/lib/mediashelf/active_fedora_helper.rb"
require "#{RAILS_ROOT}/vendor/plugins/hydra_repository/app/helpers/application_helper.rb"
require "#{RAILS_ROOT}/vendor/plugins/hydra_exhibits/app/models/ead_xml.rb"

module ApplicationHelper

  include MediaShelf::ActiveFedoraHelper
  
  def application_name
    'Hydrangea (Hydra ND Demo App)'
  end

  def generate_pid(key, content_model)
    namespace="RBSC-CURRENCY"
    #content_model="Lot"
    pid=namespace << ":" << (content_model.blank? ? '' : content_model) << key
    #pid="changeme:61"
    logger.debug("Pid to look up or generate: #{pid}")
    return pid
  end

  def asset_available(pid, content_model)
    content_model_type = nil
    args = {:id=> pid}
    opts = {}
    af_model = retrieve_af_model(content_model)
    raise "Content model #{content_model} is not of type ActiveFedora:Base" unless af_model
    raise "Content model #{af_model} does not implement find_by_fields_by_solr" unless af_model.respond_to?(:find_by_fields_by_solr)
    results = af_model.find_by_fields_by_solr(args,opts)
    if results.nil? || results.hits.nil? || results.hits.empty? || results.hits.first[SOLR_DOCUMENT_ID].nil?
      #logger.debug("Result is empty need to create new obj")
      return false
    else
      #logger.debug("result from solr: #{results.inspect}")
      return true
    end

    return false
  end

    #
  #  Link to the main browse page for the collection of items displayed
  #
  def link_to_browse()
    models_for_url= []
    values_for_url= []
    path = ''
#    if params[:genre_form_id]
#      unless params[:collection_id]
#        if !@collection.nil?
#          params.merge!({:collection_id=>@collection.pid})
#        elsif !@genre_form.nil?
#          params.merge!({:collection_id=>@genre_form.parent_id})
#        else
#          @genre_form = Component.load_instance_from_solr(params[:member_id])
#          params.merge!({:collection_id=>@genre_form.parent_id})
#        end
#      end
#      models_for_url.push("collection")
#      values_for_url.push(params[:collection_id])
#      models_for_url.push("genre_form")
#      values_for_url.push(params[:member_id])
#      link_to "Browse related content", eval("#{models_for_url.join('_')}_path(\"#{values_for_url.join('", "')}\")")
#    elsif params[:collection_id]
#      models_for_url.push("collection")
#      values_for_url.push(params[:collection_id])
#      link_to "Return to collection home", eval("#{models_for_url.join('_')}_path(\"#{values_for_url.join('", "')}\")")
#    else
      link_to "Return to collection home", collections_path
#    end
    
  end  

  def breadcrumb_builder
    breadcrumb_html = ''
    models_for_url= []
    values_for_url= []
    
    #['collection', 'component', 'page'].each do |model|
    #  constantized_model = model.classify.constantize
    #  key = "#{model}_id".to_sym
    #  if params[key]
    #    if params[:controller] == 'catalog' && model == 'item' 
    #      target = constantized_model.load_instance_from_solr(params[key])
    #      name   = target.respond_to?(:formatted_name) ? " &gt; #{target.formatted_name}" : " &gt; #{target.name}"
    #      params[:render_search].blank? ? catalog_path(params[key]) : path = catalog_path(params[key], :render_search => 'false')
    #      breadcrumb_html << link_to(name, path) 
    #    else
    #      models_for_url.push(model)
    #      values_for_url.push(params[key])
    #      target = constantized_model.load_instance_from_solr(params[key])
    #      name   = target.respond_to?(:formatted_name) ? " &gt; #{target.formatted_name}" : " &gt; #{target.name}"
    #      path   = "#{models_for_url.join('_')}_path(\"#{values_for_url.join('", "')}\")"
    #      breadcrumb_html << "#{link_to name, eval(path) } "
    #    end
    #  elsif params[:id] && (params[:controller] == 'catalog' && model == params[:document_format] || params[:controller] == model.pluralize)
    #    breadcrumb_html << " &gt; #{constantized_model.load_instance_from_solr(params[:id]).name}"
    #  end 
    #end 
    return breadcrumb_html
  end

  def search_caption
    @collection ? @collection.name : "All Collections"
  end 

end
