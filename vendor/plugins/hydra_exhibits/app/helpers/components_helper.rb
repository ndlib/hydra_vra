module ComponentsHelper

  include MediaShelf::ActiveFedoraHelper

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
