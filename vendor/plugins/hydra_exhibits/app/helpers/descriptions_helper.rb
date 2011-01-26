module DescriptionsHelper

  include MediaShelf::ActiveFedoraHelper

  def create_and_save_description(content)
    @description = create_description
    add_posted_blob_to_description(content)
    @description.save
    return @description
  end

  # Creates a File Asset and sets its label from params[:Filename]
  #
  # @return [FileAsset] the File Asset
  def create_description
    description_asset = Description.new(:namespace=>"RBSC-CURRENCY")
    logger.error("Description Create with pid #{description_asset.pid}")
    return description_asset
  end

  def add_posted_blob_to_description(content, asset=@description)
    asset.descriptiondatastream_append(:file=>content, :label=>"test", :mimeType=>"text/html")
    logger.error("List of DS: #{asset.descriptiondatastream_ids}")
  end

  # Textile textarea varies from the other methods in a few ways
  # Since we're using jeditable with this instead of fluid, we need to provide slightly different hooks for the javascript
  # * we are storing the datastream name in data-datastream-name so that we can construct a load url on the fly when initializing the textarea
  def rich_text_area(content_model,pid, datastream_name, opts={})
    field_name = "descriptiontest"
    af_model = retrieve_af_model(content_model)
    logger.error("cm:#{content_model.inspect}, pid:#{pid.inspect}, ds:#{datastream_name.inspect}")
    raise "Content model #{content_model} is not of type ActiveFedora:Base" unless af_model
    resource = af_model.load_instance(pid)
    logger.error("Model: #{af_model}, resource:#{resource.pid}")
    field_values = resource.descriptiondatastream(datastream_name).first.content
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

    body << "<#{container_tag_type.to_s} class=\"field_value textile-container field\" id=\"#{base_id}-container\">"
      # Not sure why there is we're not allowing the for the first textile to be deleted, but this was in the original helper.
      #body << "<a href=\"\" title=\"Delete '#{h(current_value)}'\" class=\"destructive field\">Delete</a>" unless z == 0
      body << "<div class=\"textile-text text\" id=\"#{base_id}-text\">#{processed_field_value}</div>"
      body << "<input class=\"textile-edit edit\" id=\"#{base_id}\" data-datastream-name=\"#{datastream_name}\" rel=\"#{field_name}\" name=\"#{name}\" value=\"#{h(field_values)}\"/>"
    body << "</#{container_tag_type}>"


    result = ""

    if opts.fetch(:multiple, true)
      result << content_tag(:ol, body, :rel=>field_name)
    else
      result << body
    end

    return result

  end

=begin
  def description_content(content_model,pid,datastream_name)
    af_model = retrieve_af_model(content_model)
    logger.error("cm:#{content_model.inspect}, pid:#{pid.inspect}")
    raise "Content model #{content_model} is not of type ActiveFedora:Base" unless af_model
    resource = af_model.load_instance(pid)
    logger.error("Model: #{af_model}, resource:#{resource.pid}")
    content= resource.descriptiondatastream(datastream_name).first.content
    return content
  end
=end

end