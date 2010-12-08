require "#{RAILS_ROOT}/vendor/plugins/hydra_repository/lib/mediashelf/active_fedora_helper.rb"
require "#{RAILS_ROOT}/vendor/plugins/hydra_repository/app/helpers/application_helper.rb"

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

end
