module ComponentsControllerHelper
 
  include MediaShelf::ActiveFedoraHelper
  
  def create_and_save_component(label, content_type, parent_id, parent_content_type)
=begin    
    if(label.include? "item")
      @asset = Component.new(:namespace=>get_namespace)
      @asset.datastreams["descMetadata"].ng_xml = EadXml.item_template
      apply_depositor_metadata(@asset)
      set_collection_type(@asset, content_type)
      @asset.update_indexed_attributes({:component_type=>{0=>"item"}})
      @asset.member_of_append(parent_id)
      @asset.save
      sc = Component.load_instance(parent_id)
      col = Collection.load_instance(sc.member_of.first.pid)
      if(!col.last_item_number.nil?)
	id_num = col.last_item_number.to_i + 1
	col.update_indexed_attributes({:last_item_number=>{0=>id_num.to_s}})
	col.save
	@asset.update_indexed_attributes({:item_id=>{0=>id_num.to_s}})
	@asset.update_indexed_attributes({[:item, :did, :unitid]=>{0=>id_num.to_s}})
        @asset.save
      end
    elsif(label.include? "subcollection")
      @asset = Component.new(:namespace=>get_namespace)
      @asset.datastreams["descMetadata"].ng_xml = EadXml.subcollection_template
      apply_depositor_metadata(@asset)
      set_collection_type(@asset, content_type)
      @asset.update_indexed_attributes({:component_type=>{0=>"subcollection"}})
      @asset.member_of_append(parent_id)
      @asset.save
      col = Collection.load_instance(parent_id)
      if(!col.last_sc_number.nil?)
	id_num = col.last_sc_number.to_i + 1
	col.update_indexed_attributes({:last_sc_number=>{0=>id_num.to_s}})
	col.save
	@asset.update_indexed_attributes({:subcollection_id=>{0=>id_num.to_s}})
        @asset.save
      end
=end
    unless label.empty?
      label = "subseries" if label == "subcollection"
      @asset = Component.new(:namespace=>get_namespace)
      @asset.datastreams["descMetadata"].ng_xml = EadXml.component_template(label)
      apply_depositor_metadata(@asset)
      set_collection_type(@asset, content_type)
      
      @asset.update_indexed_attributes({:component_type=>{0=>label}})
      @asset.save
      if !parent_content_type.empty? && parent_content_type == "collection"
        col = Collection.load_instance(parent_id)
        col.members_append(@asset.pid)
        col.save
      else
        component = Component.load_instance(parent_id)
        component.send("#{Component.child_type_relationships[label.to_sym]}_append".to_sym,@asset.pid) if Component.child_type_relationships[label.to_sym]
        component.save
      end
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


