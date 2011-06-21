module PagesControllerHelper

  include MediaShelf::ActiveFedoraHelper

  def create_and_save_page(parent_id, content_type)
    @asset = Page.new(:namespace=>get_namespace)
    apply_depositor_metadata(@asset)
    set_collection_type(@asset, content_type)
    @asset.image_part_of_append(parent_id)
    @asset.save
    @parent = Component.load_instance(parent_id)
    if(@parent.main_page.nil? || @parent.main_page.empty?)
      @parent.update_indexed_attributes({:main_page=>{0=>@asset.pid}})
      @parent.save
    end
    #commenting out the code below because
    #if(@parent.member_of.first.instance_of? Component)
    #  sc = Component.load_instance(@parent.member_of.first.pid)
    #else
    #  sc = @parent
    #end
    #col = Collection.load_instance(sc.member_of.first.pid)
    #if(!col.last_image_number.nil?)
    #  id_num = col.last_image_number.to_i + 1
    #  col.update_indexed_attributes({:last_image_number=>{0=>id_num.to_s}})
    #  col.save
    #  @asset.update_indexed_attributes({:page_id=>{0=>id_num.to_s}})
    #  @asset.save
    #end
    return @asset
  end
end

