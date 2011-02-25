module ComponentsControllerHelper
 
  include MediaShelf::ActiveFedoraHelper
  
  def create_and_save_component(label, content_type, parent_id)
    if(label.include? "item")
      @asset = Component.new(:namespace=>get_namespace)
      @asset.datastreams["descMetadata"].ng_xml = EadXml.item_template
      apply_depositor_metadata(@asset)
      set_collection_type(@asset, content_type)
      @asset.update_indexed_attributes({:component_type=>{0=>"item"}})
      @asset.member_of_append(parent_id)
      @asset.save
    elsif(label.include? "subcollection")
      @asset = Component.new(:namespace=>get_namespace)
      @asset.datastreams["descMetadata"].ng_xml = EadXml.subcollection_template
      apply_depositor_metadata(@asset)
      set_collection_type(@asset, content_type)
      @asset.update_indexed_attributes({:component_type=>{0=>"subcollection"}})
      @asset.member_of_append(parent_id)
      @asset.save
    end
    return @asset
  end

  def get_page_object(page_id)
    logger.debug "Page_ID: #{page_id}"
    @page = Page.load_instance(page_id)
    return @page
  end

  def get_item_object(item_id)
    @item = Component.load_instance(item_id)
    return @item
  end
end


