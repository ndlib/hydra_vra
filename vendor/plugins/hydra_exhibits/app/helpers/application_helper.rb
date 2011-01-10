require "#{RAILS_ROOT}/vendor/plugins/hydra_repository/lib/mediashelf/active_fedora_helper.rb"
require "#{RAILS_ROOT}/vendor/plugins/hydra_repository/app/helpers/application_helper.rb"
require "#{RAILS_ROOT}/vendor/plugins/hydra_exhibits/app/models/ead_xml.rb"

module ApplicationHelper

  include MediaShelf::ActiveFedoraHelper
  include Blacklight::SolrHelper
  include Hydra::AccessControlsEnforcement
  
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
  def render_selected_browse_facet_value(facet_solr_field, item, browse_facets)
    '<span class="selected">' +
    render_facet_value(facet_solr_field, item, :suppress_link => true) +
    '</span>' +
      ' [' + link_to("remove", collection_path(remove_browse_facet_params(facet_solr_field, item.value, params, browse_facets)), :class=>"remove") + ']'
  end

  #Remove current selected facet plus any child facets selected
  def remove_browse_facet_params(solr_facet_field, value, params, browse_facets)
    new_params = remove_facet_params(solr_facet_field, value, params)
    #iterate through browseable facets from current on down
    selected_browse_facets = get_selected_browse_facets(browse_facets)
    index = browse_facets.index(solr_facet_field)
    browse_facets.slice(index + 1, browse_facets.length - index + 1).each do |f|
      new_params = remove_facet_params(f, selected_browse_facets[f.to_sym], new_params) if selected_browse_facets[f.to_sym]
    end
    new_params
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

  def edit_and_browse_subcollection_links(subcollection)
    result = ""
    if params[:action] == "edit"
      result << "<a href=\"#{catalog_path(@document[:id], :viewing_context=>"browse")}\" class=\"browse toggle\">Browse</a>"
      result << "<span class=\"edit toggle active\">Edit Essay</span>"
    else
      result << "<span class=\"browse toggle active\">Browse</span>"
      if(subcollection.nil?)
        result << "<a href=\"#{url_for(:action => "new", :controller => "sub_collections", :content_type => "sub_collection", :collection_id => @document[:id], :selected_facets => params[:f] )}\" class=\"edit toggle\">Edit Subcollection</a>"
      else
        result << "<a href=\"#{edit_catalog_path(subcollection.id, :class => "facet_selected", :collection_id => @document[:id], :f => params[:f])}\" class=\"edit toggle\">Edit Essay</a>"
      end

    end
    # result << link_to "Browse", "#", :class=>"browse"
    # result << link_to "Edit", edit_document_path(@document[:id]), :class=>"edit"
    return result
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

  def load_essay(essay_obj)
    #af_model = retrieve_af_model(content_type)
    #logger.error("cm:#{content_type.inspect}, pid:#{pid.inspect}, ds:#{datastream_name.inspect}")
    #raise "Content model #{content_type} is not of type ActiveFedora:Base" unless af_model
    resource = essay_obj.class.load_instance(essay_obj.pid)
    logger.error("Model: #{essay_obj.class}, resource:#{resource.pid}")
    content = resource.essaydatastream(resource.essaydatastream_ids.first).first.content
    return content
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

  def link_back_to_collection(opts={:label=>'Back to facets'})
    logger.debug("params: #{params.inspect}")
    # params[:f].dup ||
    query_params =  {}
    query_params.merge!({:id=>params[:collection_id]})
    query_params.merge!({:f=>params[:f]})
    link_url = collection_path(query_params)
    link_to opts[:label], link_url    
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
    logger.debug("Param in browse div: #{params.inspect}")
    return_str = '<div>'
    facet_str=''
    browse_facet = browse_facets.first
    solr_fname = browse_facet.to_s
    display_facet = response.facets.detect {|f| f.name == solr_fname}    
    unless display_facet.nil?
      if display_facet.items.length > 0
        return_str += '<h3>' + facet_field_labels[display_facet.name] + '</h3>'
        return_str += '<ul style="display:block">'
        display_facet.items.each do |item|
          if facet_in_params?( display_facet.name, item.value )                        
            #return_str += render_selected_facet_value(display_facet.name, item)
            if browse_facets.length > 1
              #call recursively until no more facets in array
              return_str+=get_complete_facet(browse_facets, response)
              #return_str += render_browse_facet_div(browse_facets.slice(1,browse_facets.length-1), response)
            elsif browse_facets.length == 1
              return_str += render_selected_browse_facet_value(display_facet.name, item, browse_facets)
            end
          else
            return_str += '<li>'
            return_str += render_browse_facet_value(display_facet.name, item)
            return_str += '</li>'
          end
        end
        return_str += '</ul>'
      end
    end
    #return_str +=facet_str
    return_str += '</div>'
  end

  def get_complete_facet(browse_facets, response)
    return_str=''
    if params.has_key?(:f)
      temp = params[:f]
      params.delete(:f)
      logger.debug("Removing F params: #{params.inspect}, Removed F params: #{temp.inspect}")
      (@response_without_f_param, @new_document_list) = get_search_results( @extra_controller_params.merge!(:q=>build_lucene_query(params[:q])) )
      #logger.debug("Adding f again: #{params.inspect}, and the solr reponse: #{@response_without_facet.inspect}")
      browse_facet = browse_facets.first
      solr_fname = browse_facet.to_s
      display_facet = @response_without_f_param.facets.detect {|f| f.name == solr_fname}
      display_facet_with_f = response.facets.detect {|f| f.name == solr_fname}
      unless display_facet.nil?
        if display_facet.items.length > 0          
          return_str += '<ul style="display:block">'
          display_facet.items.each do |item|
            #logger.debug("Check facet value: #{facet_in_temp?( temp, display_facet.name, item.value )}, temp: #{temp.inspect}")
            return_str += '<li>'
            params[:f]=temp
            if facet_in_params?(display_facet.name, item.value )
              if display_facet_with_f.items.length > 0
                display_facet_with_f.items.each do |item_with_f|
                  return_str += render_selected_browse_facet_value(display_facet_with_f.name, item_with_f, browse_facets)
                  if browse_facets.length > 1
                    return_str += render_browse_facet_div(browse_facets.slice(1,browse_facets.length-1), response)
                  end
                end
              end
            else
              params.delete(:f)
              return_str += render_browse_facet_value(display_facet.name, item)
            end
            return_str += '</li>'
          end
          return_str += '</ul>'
        end
      end
    end
    params[:f]=temp
    return return_str
  end

  # true or false, depending on whether the field and value is in params[:f]
  def facet_in_temp?(temp, field, value)
    temp and temp[field] and temp[field].include?(value)
  end

  def display_thumnail( document )
    document[:has_part_s] ? true : false
  end

  def thumbnail_class( document )
    display_thumnail( document ) ? ' with-thumbnail' : ''
  end
  
  def document_partial_name(document)
    document[Blacklight.config[:show][:display_type]].first if document[Blacklight.config[:show][:display_type]]
  end

  def render_document_index_partial(doc, counter, action_name)
    format = document_partial_name(doc)
    begin
      render :partial=>"catalog/_#{action_name}_partials/#{format}", :locals=>{:document=>doc, :counter=>counter}      
    rescue ActionView::MissingTemplate
      render :partial=>"catalog/_#{action_name}_partials/default", :locals=>{:document=>doc}
    end
  end
  
end

