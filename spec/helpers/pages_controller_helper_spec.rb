require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
class FakePagesController
  include PagesControllerHelper
end
def helper
  @fake_controller
end
describe PagesControllerHelper do
  before(:all) do
    @fake_controller = FakePagesController.new
  end
  describe "create_and_save_page" do
    it "should create new Page object and set the parent's main_page attribute to page pid." do
      mock_page = mock("page")
      mock_item = mock("component")
#      mock_item.expects(:pid).returns("_ITEMID_").at_least_once
      Page.expects(:new).returns(mock_page)
      mock_page.expects(:item_append)
      mock_page.expects(:save)
      Component.expects(:load_instance).returns(mock_item)
      mock_page.expects(:pid).returns("_PAGEID_").at_least_once
      mock_item.expects(:main_page).at_least_once
      mock_item.expects(:update_indexed_attributes).with({:main_page=>{0=>"_PAGEID_"}})
      mock_item.expects(:save)
      helper.expects(:apply_depositor_metadata)
      helper.expects(:set_collection_type)
      helper.create_and_save_page("_ITEMID_","page")
    end
  end
end

