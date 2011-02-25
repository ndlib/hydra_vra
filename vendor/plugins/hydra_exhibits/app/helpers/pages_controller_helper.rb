module PagesControllerHelper

  include MediaShelf::ActiveFedoraHelper

  def create_and_save_page(item_id, content_type)
    @asset = Page.new(:namespace=>get_namespace)
    apply_depositor_metadata(@asset)
    set_collection_type(@asset, content_type)
    @asset.item_append(item_id)
    @asset.save
    @parent = Component.load_instance(item_id)
    if(@parent.main_page.nil? || @parent.main_page.empty?)
      @parent.update_indexed_attributes({:main_page=>{0=>@asset.pid}})
      @parent.save
    end
    return @asset
  end
end

