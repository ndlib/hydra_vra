require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PagesController do

  describe "update" do
    it "should update properties datastream and save successfully" do
      simple_request_params = {
        "id"=>"_PID_", 
	"page_id"=>"_PAGEID_",
        "content_type"=>"page",
        "field_selectors"=>{
          "properties"=>{
            "page_id"=>:page_id
          }
        }, 
        "asset"=>{
          "properties"=>{
            "page_id"=>{"0"=>"_PAGEID_"}
          }
        }
      }
      params={:page_id=>"_PAGEID_"}
      mock_page = mock("page")
      Page.expects(:find).returns(mock_page)
      update_method_args = [ { :page_id => {"0"=>"_PAGEID_"} }, {:datastreams=>"properties"} ]
      mock_page.expects(:update_indexed_attributes).with( *update_method_args ).returns({:page_id=>{"0"=>"_PAGEID_"}})
      mock_page.expects(:save)
      put :update, simple_request_params
    end
  end
  
  describe "create" do
    it "should create four datastreams (content, screen, max, thumbnail) and save the Page object" do
      mock_file = mock("File")
      filename = "Foo File"
      mock_page = Page.new
      Page.expects(:load_instance).with("_PID_").returns(mock_page)
      mime_type = "image/jpg"
      mock_page.expects(:save).at_least_once
      xhr :post, :create, :Filedata=>mock_file, :Filename=>filename, :container_id=>"_PID_"
      mock_page.datastreams.keys.should include("content")
      mock_page.datastreams.keys.should include("screen")
      mock_page.datastreams.keys.should include("thumbnail")
      mock_page.datastreams.keys.should include("max")
    end
  end

#  describe "new" do
#    it "should create new Page object and the parent's main_page attribute to page pid." do
#      mock_page = Page.new #mock("page")
#      mock_item = Component.new #mock("component")
#      mock_item.expects(:pid).returns("_ITEMID_").at_least_once
#      Page.expects(:new).returns(mock_page)
#      mock_page.expects(:item_append)
#      mock_page.expects(:save)
#      Component.expects(:load_instance).returns(mock_item)
#      mock_page.expects(:pid).returns("_PID_").at_least_once
#      mock_item.expects(:update_indexed_attributes).with({:main_page=>{0=>"_PID_"}})
#      mock_item.expects(:save)
#      xhr :post, :new, :content_type=>"page", :item_id=>"_ITEMID_"
#    end

#    it "should create new Page object and the parent's main_page attribute to page pid." do
#      mock_page = mock("page")
#      mock_page.expects(:pid).returns("_PageID_").at_least_once
#      asset = create_and_save_page.with("_ITEMID_", "page").returns(mock_page)
#    end
#  end

  describe "show" do
    it "should retreive datastream content for given datastream id" do
      simple_request_params = { 
       "id" => "_PID_",
       "field_id"=>"title",
       "datastream"=>"descMetadata",       
       "field"=>"page_id"
      }
      mock_page = mock("page")
      mock_page.stubs(:retrieve_af_model).returns("page")
      mock_page.stubs(:pid).returns("_PID_")
      mock_doc = SolrDocument.new({"page_id_t"=>["_PAGE_ID_"]})
      controller.expects(:get_solr_response_for_doc_id).returns(["solr_response",mock_doc])
      put :show, simple_request_params
      response.should have_text("_PAGE_ID_")
    end
  end

  describe "destroy" do
    it "should delete the Page identified by pid" do
      mock_obj = mock("page", :delete)
      ActiveFedora::Base.expects(:load_instance).with("__PID__").returns(mock_obj)
      delete(:destroy, :id => "__PID__")
    end
  end

end

