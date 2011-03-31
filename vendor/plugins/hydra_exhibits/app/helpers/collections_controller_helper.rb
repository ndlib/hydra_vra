module CollectionsControllerHelper

  include MediaShelf::ActiveFedoraHelper

  def create_and_save_collection(content_type)
    @asset = Collection.new(:namespace=>get_namespace)
    @asset.datastreams["descMetadata"].ng_xml = EadXml.collection_template
    apply_depositor_metadata(@asset)
    set_collection_type(@asset, content_type)
    @asset.save
    return @asset
  end
end
