module CollectionsControllerHelper

  include MediaShelf::ActiveFedoraHelper

  def create_and_save_collection(content_type)
    @asset = Collection.new(:namespace=>"RBSC-CURRENCY")
    apply_depositor_metadata(@asset)
    set_collection_type(@asset, content_type)
    @asset.datastreams["descMetadata"].ng_xml = EadXml.collection_template
    @asset.save
    return @asset
  end
end
