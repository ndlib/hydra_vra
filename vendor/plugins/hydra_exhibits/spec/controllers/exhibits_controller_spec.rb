require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

#

describe ExhibitsController do
  
  describe "new" do
    it "should create new exhibit" do
      @exhibit = mock("exhibit")
      @exhibit.stubs(:pid).returns("_PID_")
      Exhibit.expects(:new).returns(@exhibit)
      @exhibit.stubs(:selected_facets_for_params).returns("facets")
      @exhibit.expects(:save).times(2)
      xhr :get, :new, :content_type =>"exhibit", :exhibit_id=>"_PID_"     
    end
  end

  describe "update_embedded_search" do
    it "should render embedded search partial" do
      post :update_embedded_search, {:id=>"_PID_"}      
      response.should render_template "shared/_featured_search"
    end
  end

  describe "add_collection" do
    it "should add the select collection to the exhibit" do
      simple_request_params = {
       "collections_id" => "test:collection",
       "content_type"=>"exhibit"
       }
      @exhibit = mock("exhibit")
      @exhibit.stubs(:pid).returns("_PID_")
      Exhibit.expects(:load_instance).returns(@exhibit)
      mock_collection = mock("collection")
      mock_collection.stubs(:pid).returns("collection")
      ActiveFedora::Base.expects(:load_instance).with("test:collection").returns(mock_collection)
      ActiveFedora::ContentModel.expects(:known_models_for).with(mock_collection ).returns([ActiveFedora::Base])
      ActiveFedora::Base.expects(:load_instance).with("test:collection").returns(mock_collection)
      @exhibit.expects(:collections_append).with(mock_collection)
      @exhibit.expects(:save)
      put :add_collection, {:id=>"_PID_"}.merge(simple_request_params)
      response.should render_template "exhibits/_edit_settings"
    end
  end

  describe "remove_collection" do
    it "should remove the select collection from exhibit" do
      simple_request_params = {
       "collections_id" => "test:collection",
       "content_type"=>"exhibit"
       }
      @exhibit = mock("exhibit")
      @exhibit.stubs(:pid).returns("_PID_")
      Exhibit.expects(:load_instance).returns(@exhibit)
      mock_collection = mock("collection")
      mock_collection.stubs(:pid).returns("collection")
      ActiveFedora::Base.expects(:load_instance).with("test:collection").returns(mock_collection)
      ActiveFedora::ContentModel.expects(:known_models_for).with(mock_collection ).returns([ActiveFedora::Base])
      ActiveFedora::Base.expects(:load_instance).with("test:collection").returns(mock_collection)
      @exhibit.expects(:collections_remove).with(mock_collection)
      @exhibit.expects(:save)
      put :remove_collection, {:id=>"_PID_"}.merge(simple_request_params)
      response.should have_text "Removed collections relation successfully."
    end
  end

=begin
  describe "remove_facet_value" do
    it "should add the select collection to the exhibit" do
      simple_request_params = {
       "collections_id" => "test:collection",
       "content_type"=>"exhibit",
       "facet_value"=>"test value",
       "index"=>"0"
       }
      @exhibit = mock("exhibit")
      @exhibit.stubs(:pid).returns("_PID_")
      Exhibit.expects(:load_instance).returns(@exhibit)
      mock_collection = mock("collection")
      mock_collection.stubs(:pid).returns("collection")
      ActiveFedora::Base.expects(:load_instance).with("test:collection").returns(mock_collection)
      ActiveFedora::ContentModel.expects(:known_models_for).with(mock_collection ).returns([ActiveFedora::Base])
      ActiveFedora::Base.expects(:load_instance).with("test:collection").returns(mock_collection)
      @exhibit.expects(:update_indexed_attributes).with(:main_description=>{simple_request_params["index"]=>simple_request_params["facet_value"]})
      @exhibit.expects(:save)
      put :remove_facet_value, {:id=>"_PID_"}.merge(simple_request_params)
      response.should have_text "Removed facet from settings successfully."
    end
  end
=end

  describe "refresh_setting" do
    it "should render edit setting for given exhibit" do
      simple_request_params = {     
       "content_type"=>"exhibit"
       }
      @exhibit = mock("exhibit")
      @exhibit.stubs(:pid).returns("_PID_")
      @exhibit.stubs(:browse_facets).returns("should return the list of browse facet")
      Exhibit.expects(:load_instance).returns(@exhibit)
      xhr :get, :refresh_setting, {:id=>"_PID_"}.merge(simple_request_params)
      response.should render_template "exhibits/_edit_settings"
    end
  end

  describe "facet_limit_hash" do
    it "should return nil for facet_limit_for given facet field" do
      response = controller.facet_limit_for("test")
      response.should be_nil
    end
  end

  describe "facet_limit_hash" do
    it "should return facet_limit_hash from blacklight config" do
      response = controller.facet_limit_hash
      response.should_not be_nil
    end
  end

end
