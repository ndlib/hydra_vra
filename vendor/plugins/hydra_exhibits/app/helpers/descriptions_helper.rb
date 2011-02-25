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
    description_asset = Description.new(:namespace=>get_namespace)
    logger.error("Description Create with pid #{description_asset.pid}")
    return description_asset
  end

  def add_posted_blob_to_description(content, asset=@description)
    asset.descriptiondatastream_append(:file=>content, :label=>"test", :mimeType=>"text/html")
    #logger.error("List of DS: #{asset.descriptiondatastream_ids}")
  end

end