require "#{RAILS_ROOT}/vendor/plugins/hydra_repository/lib/mediashelf/active_fedora_helper.rb"
require "#{RAILS_ROOT}/vendor/plugins/hydra_repository/app/helpers/application_helper.rb"
require "#{RAILS_ROOT}/vendor/plugins/hydra_exhibits/app/models/ead_xml.rb"

module ApplicationHelper

  include MediaShelf::ActiveFedoraHelper
  
  def application_name
    'Hydrangea (Hydra ND Demo App)'
  end

  # Standard display of a facet value in a list. Used in both _facets sidebar
  # partial and catalog/facet expanded list. Will output facet value name as
  # a link to add that to your restrictions, with count in parens. 
  # first arg item is a facet value item from rsolr-ext.
  # options consist of:
  # :suppress_link => true # do not make it a link, used for an already selected value for instance
  def render_browse_facet_value(facet_solr_field, item, options ={})    
    
    link_to_unless(options[:suppress_link], item.value, collection_path(add_facet_params_and_redirect(facet_solr_field, item.value).merge!({:class=>"facet_select", :action=>"show"}))) + " (" + format_num(item.hits) + ")"
  end

  # Standard display of a SELECTED facet value, no link, special span
  # with class, and 'remove' button.
  def render_selected_facet_value(facet_solr_field, item)
    '<span class="selected">' +
    render_facet_value(facet_solr_field, item, :suppress_link => true) +
    '</span>' +
      ' [' + link_to("remove", collection_path(remove_facet_params(facet_solr_field, item.value, params)), :class=>"remove") + ']'
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
  
  def app_rich_text_area(content_type,pid, datastream_name, opts={})
    field_name = "essay_content"
    af_model = retrieve_af_model(content_type)
    logger.error("cm:#{content_type.inspect}, pid:#{pid.inspect}, ds:#{datastream_name.inspect}")
    raise "Content model #{content_type} is not of type ActiveFedora:Base" unless af_model
    resource = af_model.load_instance(pid)
    logger.error("Model: #{af_model}, resource:#{resource.pid}")
    field_values = resource.essaydatastream(datastream_name).first.content
    if opts.fetch(:multiple, true)
      container_tag_type = :li
    else
      field_values = [field_values.first]
      container_tag_type = :span
    end
    body = ""
    base_id = "base_id"
    name = "asset[#{datastream_name}][#{field_name}]"
    processed_field_value = white_list( RedCloth.new(field_values, [:sanitize_html]).to_html)

    body << "<#{container_tag_type.to_s} class=\"field_value essay-textarea-container field\" id=\"#{base_id}-container\">"
      # Not sure why there is we're not allowing the for the first textile to be deleted, but this was in the original helper.
      #body << "<a href=\"\" title=\"Delete '#{h(current_value)}'\" class=\"destructive field\">Delete</a>" unless z == 0
      body << "<div class=\"textile-text text\" id=\"#{base_id}-text\">#{processed_field_value}</div>"
      body << "<input class=\"textile-edit edit\" id=\"#{base_id}\"  data-pid=\"#{pid}\" data-content-type=\"#{content_type}\" data-datastream-name=\"#{datastream_name}\" rel=\"#{field_name}\" name=\"#{name}\" value=\"#{h(field_values)}\"/>"
    body << "</#{container_tag_type}>"


    result = ""

    if opts.fetch(:multiple, true)
      result << content_tag(:ol, body, :rel=>field_name)
    else
      result << body
    end

    return result

  end

  def essay_text_area_insert_link(datastream_name, opts={})
    field_name = "essay_content"
    link_text = "Add #{(opts[:label]).to_s.camelize.titlecase}"
    "<a class='addval rich-textarea' href='#' data-datastream-name=\"#{datastream_name}\" content-type=\"#{opts[:content_type]}\" rel=\"#{field_name}\" title='#{link_text}'>#{link_text}</a>"    
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

  def render_browse_facet_div(browse_facets, response)
    return_str = '<div>'
    browse_facet = browse_facets.first
    solr_fname = browse_facet.to_s
    display_facet = response.facets.detect {|f| f.name == solr_fname}
    unless display_facet.nil?
      if display_facet.items.length > 0
        return_str += '<h3>' + facet_field_labels[display_facet.name] + '</h3>'
        return_str += '<ul style="display:block">'
        display_facet.items.each do |item|
          return_str += '<li>'
          if facet_in_params?( display_facet.name, item.value )
            return_str += render_selected_facet_value(display_facet.name, item)
            if browse_facets.length > 1
            #call recursively until no more facets in array
            return_str += render_browse_facet_div(browse_facets.slice(1,browse_facets.length-1), response)
          end
          else
            return_str += render_browse_facet_value(display_facet.name, item)     
          end
          return_str += '</li>'
        end
        return_str += '</ul>'
      end
    end
    return_str += '</div>'
  end

end
