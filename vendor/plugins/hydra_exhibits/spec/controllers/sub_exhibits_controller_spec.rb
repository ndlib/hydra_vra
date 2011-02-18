require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

#

describe SubExhibitsController do

  describe "update" do
    it "should add given featured items to sub-exhibit" do
      mock_asset = mock("asset")
      mock_item1 = mock("item1")
      mock_item2 = mock("item2")
      mock_item3 = mock("item3")
      #stubs(:retrieve_af_model).with("content_type").returns(SubExhibit)
      SubExhibit.expects(:load_instance).with("_PID_").returns(mock_asset)
      simple_request_params = { "featured_action"=>"add",
       "featured_items" => "test:item1,test:item2,test:item3",
       "content_type"=>"conten_type"
       }
      #logger.debug (mock_item1.inspect)
      ActiveFedora::Base.expects(:load_instance).with("test:item1").returns(mock_item1)
      mock_asset.expects(:featured_append).with(mock_item1)
      mock_item1.expects(:save)
      mock_asset.expects(:save)

      ActiveFedora::Base.expects(:load_instance).with("test:item2").returns( mock_item2)
      mock_asset.expects(:featured_append).with(mock_item2)
      mock_item2.expects(:save)
      mock_asset.expects(:save)

      ActiveFedora::Base.expects(:load_instance).with("test:item3").returns( mock_item3)
      mock_asset.expects(:featured_append).with(mock_item3)
      mock_item3.expects(:save)
      mock_asset.expects(:save)      
      put :update, {:id=>"_PID_"}.merge(simple_request_params)
      response.should render_template "shared/_show_featured"
    end
    it "should remove given item from featured items in sub-exhibit" do
      mock_asset = mock("asset")
      mock_item1 = mock("item1")
      mock_item2 = mock("item2")
      mock_item3 = mock("item3")

      SubExhibit.expects(:load_instance).with("_PID_").returns(mock_asset)
      simple_request_params = { "featured_action"=>"remove",
       "item_id" => "test:item1",
       "content_type"=>"conten_type"
       }
      logger.debug (mock_item1.inspect)
      mock_item1.stubs(:pid).returns("item1")
      ActiveFedora::Base.expects(:load_instance).with("test:item1").returns(mock_item1)
      mock_asset.expects(:featured_remove).with(mock_item1)
      mock_item1.expects(:save)
      mock_asset.expects(:save)
      put :update, {:id=>"_PID_"}.merge(simple_request_params)
      response.should have_text  "Successfully removed item1 from featured list"
    end
  end

  describe "new" do
    before(:each) do
      @sub_exhibit = mock("sub_exhibit")
      @sub_exhibit.stubs(:selected_facets).returns("return facet list")
      @sub_exhibit.stubs(:id).returns("_PID_")
      @sub_exhibit.stubs(:selected_facets_for_params).returns("return facet list")
      SubExhibit.expects(:new).returns(@sub_exhibit)
      mock_ds = Hash.new("datastreams_in_memory"=>{"rightsMetadata"=> {"person"=>{"person1"=>"read"}}})
      mock_rights_ds = mock_ds["rightsMetadata"]
      @sub_exhibit.expects(:datastreams_in_memory).returns(mock_ds)
      #@sub_exhibit.datastreams["rightsMetadata"]={"rightsMetadata"=> {"person"=>{"person1"=>"read"}}}
      mock_rights_ds.expects(:update_permissions).with({"group"=>{"public"=>"read"}}).returns("update permission")
      @sub_exhibit.expects(:save)
    end
    it "should create new subexhibit" do
      xhr :get, :new, :content_type =>"sub_exhibit"
    end
    it "should add the selected_facets params to sub_exhibit" do
      simple_request_params = { "selected_facets"=>{:test=>"facets"}}
      @sub_exhibit.expects(:selected_facets_append)
      @sub_exhibit.expects(:save)
      xhr :get, :new, {:content_type =>"sub_exhibit"}.merge(simple_request_params)      
    end  
    it "should add sub_exhibit to exhibit" do
      simple_request_params = { "exhibit_id"=>"test:exhibit"}
      mock_exhibit=mock("exhibit")
      ActiveFedora::Base.expects(:load_instance).with('test:exhibit').returns(mock_exhibit)
      @sub_exhibit.expects(:subset_of_append).with(mock_exhibit)
      @sub_exhibit.expects(:save)
      mock_exhibit.expects(:save)
      xhr :get, :new, {:content_type =>"sub_exhibit"}.merge(simple_request_params)
    end
  end

end
