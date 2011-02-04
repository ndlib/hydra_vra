require "#{RAILS_ROOT}/vendor/plugins/hydra_repository/lib/mediashelf/active_fedora_helper.rb"
require "#{RAILS_ROOT}/vendor/plugins/hydra_exhibits/app/models/ead_xml.rb"
require 'cgi'

module ApplicationHelper

  include MediaShelf::ActiveFedoraHelper
  include Blacklight::SolrHelper
  include Hydra::AccessControlsEnforcement
  include HydraHelper
  
  def application_name
    'Hydrangea (ND Demo App)'
  end

  # used in the _index_partials/_collection view
  def collection_field_names
    Blacklight.config[:collections_index_fields][:field_names]
  end

  # used in the _index_partials/_collection view
  def collection_field_labels
    Blacklight.config[:collections_index_fields][:labels]
  end

  def item_field_names
    Blacklight.config[:items_index_fields][:field_names]
  end

  # used in the _index_partials/_collection view
  def item_field_labels
    Blacklight.config[:items_index_fields][:labels]
  end

  # Standard display of a facet value in a list. Used in both _facets sidebar
  # partial and catalog/facet expanded list. Will output facet value name as
  # a link to add that to your restrictions, with count in parens. 
  # first arg item is a facet value item from rsolr-ext.
  # options consist of:
  # :suppress_link => true # do not make it a link, used for an already selected value for instance
  def render_browse_facet_value(facet_solr_field, item, options ={})
    p = params.dup
    #p.delete(:f)
    p.delete(:q)
    p.delete(:commit)
    p.delete(:search_field)
    p.delete(:controller)
    p.merge!(:id=>params[:exhibit_id]) if p[:exhibit_id]
    p = add_facet_params(facet_solr_field,item.value,p)
    link_to(item.value, exhibit_path(p.merge!({:class=>"browse_facet_select", :action=>"show"})), :style=>"text-decoration:none;border-bottom:medium none")
  end

  # Standard display of a SELECTED facet value, no link, special span
  # with class, and 'remove' button.
  def render_selected_browse_facet_value(facet_solr_field, item, browse_facets)
    remove_params = remove_browse_facet_params(facet_solr_field, item.value, params, browse_facets)
    remove_params.delete(:render_search) #need to remove if we are in search view and click takes back to browse
    remove_params.merge!(:id=>params[:exhibit_id]) if params[:exhibit_id]
    remove_params.delete(:controller)
    '<span class="selected">' +
      link_to("-", exhibit_path(remove_params.merge!(:action=>"show")), :class=>"browse_facet", :style=>"text-decoration:none;border-bottom:medium none") + ' ' +
    link_to("#{item.value}", exhibit_path(remove_params.merge!(:action=>"show")), :class=>"remove", :style=>"text-decoration:none;border-bottom:medium none") +
    '</span>'
      
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

  alias :hydra_edit_and_browse_links :edit_and_browse_links

  def edit_and_browse_links
=begin
logger.debug("Params in edit_and_browse_links: #{params.inspect}")
    asset = load_af_instance_from_solr(params[:id])
    the_model = ActiveFedora::ContentModel.known_models_for( asset ).first
    logger.debug("Model in edit_and_browse_links: #{the_model.inspect}")
=end
    if params[:exhibit_id]
      result = ""
      if params[:action] == "edit"
        browse_params = params.dup
        browse_params.delete(:action)
        browse_params.delete(:controller)
        browse_params.merge!(:viewing_context=>"browse")
        result << "<a href=\"#{catalog_path(@document[:id], browse_params)}\" class=\"browse toggle\">View</a>"
        result << "<span class=\"edit toggle active\">Edit</span>"
      else
        edit_params = params.dup
        edit_params.delete(:viewing_context)
        edit_params.delete(:action)
        edit_params.delete(:controller)
        logger.debug("Edit params: #{edit_params.inspect}")
        result << "<span class=\"browse toggle active\">View</span>"
        result << "<a href=\"#{edit_catalog_path(@document[:id], edit_params)}\" class=\"edit toggle\">Edit</a>"
      end
    else
      hydra_edit_and_browse_links
    end    
  end

  def edit_and_browse_exhibit_links(exhibit)
    result = ""
    if params[:action] == "edit"
      result << "<a href=\"#{exhibit_path(params[:exhibit_id])}\" class=\"browse toggle\">View</a>"
      result << "<span class=\"edit toggle active\">Edit</span>"
    else
      result << "<span class=\"browse toggle active\">View</span>"
      result << "<a href=\"#{edit_catalog_path(@document[:id], :class => "edit_exhibit", :render_search=>"false")}\" class=\"edit toggle\">Edit</a>"
    end
    return result
  end

  def edit_and_browse_subexhibit_links(subexhibit)
    result = ""
    if params[:action] == "edit"
      browse_params = params.dup
      browse_params.delete(:action)
      browse_params.delete(:controller)
      browse_params.merge!(:viewing_context=>"browse")
      result << "<a href=\"#{exhibit_path(browse_params.merge!(:id=>params[:exhibit_id]))}\" class=\"browse toggle\">View</a>"
      result << "<span class=\"edit toggle active\">Edit</span>"
    else
      result << "<span class=\"browse toggle active\">View</span>"
      if(subexhibit.nil?)
        result << "<a href=\"#{url_for(:action => "new", :controller => "sub_exhibits", :content_type => "sub_exhibit", :exhibit_id => @document[:id], :selected_facets => params[:f])}\" class=\"edit toggle\">Edit</a>"
      else
        result << "<a href=\"#{edit_catalog_path(subexhibit.id, :class => "facet_selected", :exhibit_id => @document[:id], :f => params[:f], :render_search=>"false")}\" class=\"edit toggle\">Edit</a>"
        #edit_params = params.dup
        #edit_params.delete(:viewing_context)
        #edit_params.delete(:action)
        #edit_params.delete(:controller)
        #result << "<a href=\"#{edit_catalog_path(subexhibit.id, edit_params)}\" class=\"edit toggle\">Edit</a>"
      end

    end
    # result << link_to "Browse", "#", :class=>"browse"
    # result << link_to "Edit", edit_document_path(@document[:id]), :class=>"edit"
    return result
  end

   def custom_radio_button(resource, datastream_name, field_key, opts={})
    field_name = field_name_for(field_key)
    field_values = get_values_from_datastream(resource, datastream_name, field_key, opts)
    base_id = generate_base_id(field_name, field_values.first, field_values, opts.merge({:multiple=>false}))
    result = ""
    h_name = OM::XML::Terminology.term_hierarchical_name(*field_key)
    field_values.each_with_index do |current_value, z|
      name = "asset[#{datastream_name}][#{field_name}][#{z}][#{resource.pid}]"
      logger.debug("field_values : #{current_value}")
      result << radio_button_tag (name, opts.first[0], (opts.first[0].to_s==current_value),:data_pid=>resource.pid,:datastream=>"asset[#{datastream_name}][#{field_name}][#{z}]", :class=>"fieldselector", :rel=>h_name)      
      result << " #{opts.first[1]}"
    end
    return result
  end

  def custom_text_field(resource, datastream_name, field_key, opts={})
    field_name = field_name_for(field_key)
    field_values = get_values_from_datastream(resource, datastream_name, field_key, opts)
    content_type = ActiveFedora::ContentModel.known_models_for( resource ).first
    if content_type.nil?
      raise "Unknown content type for the object with pid #{@obj.pid}"
    end
    if opts.fetch(:multiple, true)
      container_tag_type = :li
    else
      field_values = [field_values.first]
      container_tag_type = :span
    end

    body = ""

    field_values.each_with_index do |current_value, z|
      base_id = generate_base_id(field_name, current_value, field_values, opts)
      name = "asset[#{datastream_name}][#{field_name}][#{z}]"
      body << "<#{container_tag_type.to_s} class=\"custom-editable-container field\" id=\"#{base_id}-container\">"
        body << "<a href=\"\" title=\"Delete '#{h(current_value)}'\" class=\"destructive field\">Delete</a>" unless z == 0
        body << "<span class=\"editable-text text\" id=\"#{base_id}-text\">#{h(current_value)}</span>"
        body << "<input class=\"editable-edit edit\" id=\"#{base_id}\" data-pid=\"#{resource.pid}\" data-content-type=\"#{content_type}\" data-datastream-name=\"#{datastream_name}\" rel=\"#{field_name}\" name=\"#{name}\" value=\"#{h(current_value)}\"/>"
      body << "</#{container_tag_type}>"
    end
    result = field_selectors_for(datastream_name, field_key)
    if opts.fetch(:multiple, true)
      result << content_tag(:ol, body, :rel=>field_name)
    else
      result << body
    end

    return result
  end
  
  def custom_rich_text_area(resource, datastream_name, datastream_name_key, opts={})
    content_type = ActiveFedora::ContentModel.known_models_for( resource ).first
    if content_type.nil?
      raise "Unknown content type for the object with pid #{@obj.pid}"
    end
    logger.error("Model: #{content_type}, resource:#{resource.pid}")
    if opts.fetch(:multiple, true)
      container_tag_type = :li
    else
      field_values = [field_values.first]
      container_tag_type = :span
    end
    if opts.fetch(:datastream, true)
      field_name = datastream_name
      field_values = resource.content
      body = ""
      base_id = "base_id"
      name = "asset[#{datastream_name_key}][#{field_name}]"
      processed_field_value = white_list( RedCloth.new(field_values, [:sanitize_html]).to_html)

      body << "<#{container_tag_type.to_s} class=\"field_value description-textarea-container field\" id=\"#{base_id}-container\">"
        # Not sure why there is we're not allowing the for the first textile to be deleted, but this was in the original helper.
        #body << "<a href=\"\" title=\"Delete '#{h(current_value)}'\" class=\"destructive field\">Delete</a>" unless z == 0
        body << "<div class=\"textile-text text\" id=\"#{base_id}-text\">#{processed_field_value}</div>"
        body << "<input class=\"textile-edit edit\" id=\"#{base_id}\"  data-pid=\"#{resource.pid}\"data-content-type=\"#{content_type}\"
                  data-datastream-name=\"#{datastream_name}\" rel=\"#{field_name}\" name=\"#{name}\" load-from-datastream=\"true\" value=\"#{h(field_values)}\"/>"
      body << "</#{container_tag_type}>"

      result = ""
    else
      field_name = field_name_for(datastream_name_key)
      field_values = get_values_from_datastream(resource, datastream_name, datastream_name_key, opts)
      body = ""

    field_values.each_with_index do |current_value, z|
      base_id = generate_base_id(field_name, current_value, field_values, opts)
      name = "asset[#{datastream_name}][#{field_name}][#{z}]"
      processed_field_value = white_list( RedCloth.new(current_value, [:sanitize_html]).to_html)

      body << "<#{container_tag_type.to_s} class=\"field_value description-textarea-container field\" id=\"#{base_id}-container\">"
        # Not sure why there is we're not allowing the for the first textile to be deleted, but this was in the original helper.
        body << "<a href=\"\" title=\"Delete '#{h(current_value)}'\" class=\"destructive field\">Delete</a>" unless z == 0
        body << "<div class=\"textile-text text\" id=\"#{base_id}-text\">#{processed_field_value}</div>"
        body << "<input class=\"textile-edit edit\" id=\"#{base_id}\" data-pid=\"#{resource.pid}\"data-content-type=\"#{content_type}\"
                  data-datastream-name=\"#{datastream_name}\" rel=\"#{field_name}\" name=\"#{name}\" load-from-datastream=\"false\"  value=\"#{h(current_value)}\"/>"
      body << "</#{container_tag_type}>"
    end
    result = field_selectors_for(datastream_name, datastream_name_key)
    end
    if opts.fetch(:multiple, true)
      result << content_tag(:ol, body, :rel=>field_name, :title=>"description_title")
    else
      result << body
    end
    return result
  end

  def description_text_area_insert_link(datastream_name, opts={})
    field_name = "description_content"
    link_text = "Add #{(opts[:label]).to_s.camelize.titlecase}"
    "<input type=\"button\" class='addval rich-textarea button' href='#' data-datastream-name=\"#{datastream_name}\" content-type=\"#{opts[:content_type]}\" rel=\"#{field_name}\" title='#{link_text}' value='#{link_text}'/>"    
  end

  def load_description(description_obj)
    #af_model = retrieve_af_model(content_type)
    #logger.error("cm:#{content_type.inspect}, pid:#{pid.inspect}, ds:#{datastream_name.inspect}")
    #raise "Content model #{content_type} is not of type ActiveFedora:Base" unless af_model
    resource = description_obj.class.load_instance(description_obj.pid)
    logger.error("Model: #{description_obj.class}, resource:#{resource.pid}")
    content = resource.descriptiondatastream(resource.descriptiondatastream_ids.first).first.content
    return content
  end

  def add_facet_params(field, value, p=nil)
    p = params.dup if p.nil?
    p[:f]||={}
    p[:f][field] ||= []
    p[:f][field].push(value)
    p
  end

  def document_link_to_exhibit_sub_exhibit(label, document, counter)
    sub_exhibit = load_af_instance_from_solr(document)
    if !sub_exhibit.nil? && sub_exhibit.respond_to?(:selected_facets)
      p = params.dup
      #remove any previous f params from search
      p.delete(:f)
      sub_exhibit.selected_facets.each_pair do |facet_solr_field,value|
        p = add_facet_params(facet_solr_field,value,p)
      end
      p.delete(:commit)
      p.delete(:search_field)
      p.delete(:q)
      link_to(label, exhibit_path(p.merge!({:id=>sub_exhibit.subset_of_ids.first, :class=>"facet_select", :action=>"show", :exhibit_id=>sub_exhibit.subset_of_ids.first})))
    else
      link_to_document(document, :label => Blacklight.config[:show][:heading].to_sym, :counter => (counter + 1 + @response.params[:start].to_i))
    end
  end

  alias :blacklight_link_to_with_data :link_to_with_data

  # Need to override this to get exhibit_id's in the url if defined
  # Tried to override link_to_document but had problems overriding one
  # in hydra_repository plugin because of load order issues
  def link_to_with_data(*args, &block)
    path = args.second
    params[:controller] == "exhibits" ? exhibit_id = params[:id] : exhibit_id = params[:exhibit_id]
    use_amp = path.include?("?")
    if exhibit_id
      use_amp ? path << "&" : path << "?"
      path << "exhibit_id=#{CGI::escape(exhibit_id)}"
      path << "&render_search=false" unless params[:render_search].blank? && params[:controller] == "catalog"
      #always go to browse view first when viewing a catalog item
      path << "&viewing_context=browse"
      use_amp = true
    end

    if params[:f] && (params[:controller] != "catalog" || !params[:render_search].blank?)
      params[:f].each_pair do |facet,values|
        values.each do |value|
          use_amp ? path << "&" : path << "?"
          path << "f[#{facet}][]=#{CGI::escape(value)}"
          use_amp = true
        end
      end
    end

    temp = args
    args = []
    args << temp.first
    args << path
    args << temp.slice(3) if temp.length > 2
    blacklight_link_to_with_data(*args, &block)
  end

  def link_to_exhibit(opts={})
    # params[:f].dup ||
    query_params =  {}
    opts[:exhibit_id] ? exhibit_id = opts[:exhibit_id] : exhibit_id = params[:exhibit_id]
    opts[:f] ? f = opts[:f] : f = params[:f]
    #if opts[:f]
     # f = opts[:f]
    #end 
    query_params.merge!({:id=>exhibit_id})
    query_params.merge!({:f=>f}) if f && !f.empty? && !params[:render_search].blank?
    link_url = exhibit_path(query_params)
    opts[:label] = exhibit_id unless opts[:label]
    opts[:style] ? link_to(opts[:label], link_url, :style=>opts[:style]) : link_to(opts[:label], link_url)
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

  def render_browse_facet_div
    initialize_exhibit if @exhibit.nil?
    @exhibit.nil? ? '' : get_browse_facet_div(@browse_facets,@browse_response,@extra_controller_params)
  end

  def get_browse_facet_div(browse_facets, response, extra_controller_params)
    #require 'ruby-debug'
    #debugger
    #true
    logger.debug("Param in browse div: #{params.inspect}")
    return_str = ''
    browse_facet = browse_facets.first
    solr_fname = browse_facet.to_s
    if params.has_key?(:f) && params[:f][browse_facet]
      temp = params[:f].dup
      logger.debug("Removing F params: #{params.inspect}, Removed F params: #{temp.inspect}")
      browse_facets.each do |facet|
        params[:f].delete(facet.to_s)
      end
      logger.debug("Params after delete: #{params.inspect}")
      (response_without_f_param, @new_document_list) = get_search_results(extra_controller_params)
    else
      response_without_f_param = response
    end
    display_facet = response_without_f_param.facets.detect {|f| f.name == solr_fname}
    display_facet_with_f = response.facets.detect {|f| f.name == solr_fname}
    unless display_facet.nil?
      if display_facet.items.any?
        return_str += '<h3 class="facet-heading">' + facet_field_labels[display_facet.name] + '</h3>'
        return_str += '<ul>'
        display_facet.items.each do |item|
          #logger.debug("Check facet value: #{facet_in_temp?( temp, display_facet.name, item.value )}, temp: #{temp.inspect}")
          return_str += '<li>'
          params[:f]=temp if temp
          if facet_in_params?(display_facet.name, item.value )
            if display_facet_with_f.items.any?
              display_facet_with_f.items.each do |item_with_f|
                return_str += render_selected_browse_facet_value(display_facet_with_f.name, item_with_f, browse_facets)
                if browse_facets.length > 1
                  return_str += get_browse_facet_div(browse_facets.slice(1,browse_facets.length-1), response, extra_controller_params)
                end
              end
            end
          else
            browse_facets.each do |facet|
              params[:f].delete(facet.to_s) if params[:f]
            end
            return_str += render_browse_facet_value(display_facet.name, item)
          end
          return_str += '</li>'
        end
        return_str += '</ul>'
      end
    end
    logger.debug("Temp F params are: #{params.inspect}")
    params[:f]=temp if temp 
    return_str
  end

  # true or false, depending on whether the field and value is in params[:f]
  def facet_in_temp?(temp, field, value)
    temp and temp[field] and temp[field].include?(value)
  end

  def get_featured_available(content, featured_query_to_append)
    q = build_lucene_query(params[:q])
    featured_query = [featured_query_to_append]
    lucene_query = "#{featured_query} AND #{q}" unless featured_query.empty?
    extra_controller_params = {}
    get_search_results(extra_controller_params.merge!(:q=>lucene_query) )    
  end

  def get_selected_browse_facets(browse_facets)
    selected = {}
    if params[:f]
      browse_facets.each do |facet|
        selected.merge!({facet.to_sym=>params[:f][facet].first}) if params[:f][facet]
      end
    end
    selected
  end

  def browse_facet_selected?(browse_facets)
    browse_facets.each do |facet|
      return true if params[:f] and params[:f][facet]
    end
    return false
  end

  def render_item_partial(doc, action_name, locals={})
    format = document_partial_name(doc)
    #begin
      Rails.logger.debug("attempting to render #{format}/_#{action_name}")
      render :partial=>"#{format}/#{action_name}", :locals=>{:document=>doc}.merge(locals)
    #rescue ActionView::MissingTemplate
    #  Rails.logger.debug("rendering default partial catalog/_#{action_name}_partials/default")
    #  render :partial=>"catalog/_#{action_name}_partials/default", :locals=>{:document=>doc}.merge(locals)
    #end
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

  def render_document_index_partial(doc, title, counter, action_name, thumbnail=nil)
    format = document_partial_name(doc)
    logger.debug("format: #{format}")
    begin
      locals = {:document=>doc, :counter=>counter, :title=>title}
      locals.merge!(:thumbnail=>thumbnail) unless thumbnail.nil?
      render :partial=>"catalog/_#{action_name}_partials/#{format}", :locals=>locals      
    rescue ActionView::MissingTemplate
      render :partial=>"catalog/_#{action_name}_partials/default", :locals=>{:document=>doc}
    end
  end

  alias :access_controls_build_lucene_query :build_lucene_query

  def build_lucene_query(user_query)
    q = access_controls_build_lucene_query(user_query)
    if params[:exhibit_id]
      ex = Exhibit.load_instance_from_solr(params[:exhibit_id])
      unless ex.nil?
        exhibit_members_query = ex.build_members_query
        q = "#{exhibit_members_query} AND #{q}" unless exhibit_members_query.empty?
      end
    end
    q = "#{q} AND NOT _query_:\"info\\\\:fedora/afmodel\\\\:Exhibit\" AND NOT _query_:\"info\\\\:fedora/afmodel\\\\:SubExhibit\" AND NOT _query_:\"info\\\\:fedora/afmodel\\\\:Description\" "
  end

  def get_collections(content, user_query_to_append)
    q = build_lucene_query(params[:q])
    collection_query = [user_query_to_append]
    if params[:exhibit_id]
      ex = Exhibit.load_instance_from_solr(params[:exhibit_id])      
    end    
    lucene_query = "#{collection_query} AND #{q}" unless collection_query.empty?
    extra_controller_params ||= {}
    (@collection_response, @collection_document_list) = get_search_results( extra_controller_params.merge!(:q=>lucene_query))
    render :partial => "shared/add_collections", :locals => {:collection_list => @collection_response, :facet_name => nil, :facet_value => nil, :content=>content, :asset=>ex}    
  end

   def initialize_exhibit
    require_fedora
    require_solr
    if params[:controller] == "exhibits"
      exhibit_id = params[:id]
    else
      exhibit_id = params[:exhibit_id]
    end

    unless exhibit_id
      logger.info("No exhibit was found for id #{exhibit_id}")
      return
    end

    begin
      @exhibit = Exhibit.load_instance_from_solr(exhibit_id) 
      @browse_facets = @exhibit.browse_facets
      @facet_subsets_map = @exhibit.facet_subsets_map
      @selected_browse_facets = get_selected_browse_facets(@browse_facets) 
      #subset will be nil if the condition fails
      @subset = @facet_subsets_map[@selected_browse_facets] if @selected_browse_facets.any? && @facet_subsets_map[@selected_browse_facets]
      #call exhibit.discriptions once since querying solr everytime on inbound relationship
      if browse_facet_selected?(@browse_facets)
        @subset.nil? ? @descriptions = [] : @descriptions = @subset.descriptions
      else
        #use exhibit descriptions
        @descriptions = @exhibit.descriptions
      end
      logger.debug("Description: #{@descriptions}, Subset:#{@subset.inspect}")
      @extra_controller_params ||= {}
      exhibit_members_query = @exhibit.build_members_query
      lucene_query = build_lucene_query(params[:q])
      lucene_query = "#{exhibit_members_query} AND #{lucene_query}" unless exhibit_members_query.empty?
      (@response, @document_list) = get_search_results( @extra_controller_params.merge!(:q=>lucene_query))
      @browse_response = @response
      @browse_document_list = @document_list
    rescue Exception=>e
      logger.info("No exhibit was found for id #{exhibit_id}: #{e.to_s}")
    end
  end

  #  Expects Array of PIDs and returns array of Response and DocumentList
  def get_pids_search_results(pid_array)
    fq = ActiveFedora::SolrService.construct_query_for_pids(pid_array)
    extra_controller_params ||= {}
    extra_controller_params.merge!(:q=>build_lucene_query(params[:q]))
    extra_controller_params.merge!(:fq=>fq)
    get_search_results(extra_controller_params)
  end

  # Apply a class to the body element if the browse conditions are met.
  # TODO: Extend this method to support exhibit-specific themes
  def set_page_style
    @body_class ||= "exhibit" if !params[:exhibit_id].blank? || params[:controller] == "exhibits"
  end

  def get_exhibits_list
    Exhibit.find_by_solr(:all).hits.map{|result| Exhibit.load_instance_from_solr(result["id"])}
  end

end

