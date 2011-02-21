require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ComponentsController do

  describe "update" do
    it "should update properties datastream and save successfully" do
      mock_component = mock("component")
      Component.expects(:load_instance).with("_PID_").returns(mock_component)
      mock_component.expects(:update_indexed_attributes).with({:main_page=>{0=>"_MAINPAGEID_"}})
      mock_component.expects(:save)
      mock_component.expects(:pid).returns("_PID_")
      simple_request_params = {
        "id"=>"_PID_", 
	"description_id"=>"_MAINPAGEID_",
        "content_type"=>"component",
        "field_selectors"=>{
          "properties"=>{
            "main_page"=>:main_page
          }
        }, 
        "asset"=>{
          "properties"=>{
            "main_page"=>{"0"=>"_MAINPAGEID_"}
          }
        }
      }
      put :update, simple_request_params
    end

    it "should update unique id in properties datastream and save successfully" do
      mock_component = mock("component")
      Component.expects(:load_instance).with("_PID_").returns(mock_component)
      mock_component.expects(:update_indexed_attributes).with({:subcollection_id=>{"0"=>"_SUBCOLLECTIONID_"}})
      mock_component.expects(:save)
      mock_component.expects(:pid).returns("_PID_")
      simple_request_params = {
        "id"=>"_PID_",
        "content_type"=>"component",
        "field_selectors"=>{
          "properties"=>{
            "subcollection_id"=>:subcollection_id
          }
        }, 
        "asset"=>{
          "properties"=>{
            "subcollection_id"=>{"0"=>"_SUBCOLLECTIONID_"}
          }
        }
      }
      put :update, simple_request_params
    end

    it "should update descMetadata datastream and save successfully" do
      mock_component = mock("component")
      Component.expects(:find).with("_PID_").returns(mock_component)

      update_method_args = [ { [:dsc, :collection, :did, :unitid] => {"0"=>"_UNITID_"} }, {:datastreams=>"descMetadata"} ]
      mock_component.expects(:update_indexed_attributes).with( *update_method_args ).returns({"dsc_0_collection_0_did_0_unitid"=>{"0"=>"_UNITID_"}})
      mock_component.expects(:save)

      nokogiri_request_params = {
        "id"=>"_PID_", 
        "content_type"=>"component",
        "field_selectors"=>{
          "descMetadata"=>{
            "dsc_0_collection_0_did_0_unitid"=>[:dsc, :collection, :did, :unitid]
          }
        }, 
        "asset"=>{
          "descMetadata"=>{
            "dsc_0_collection_0_did_0_unitid"=>{"0"=>"_UNITID_"}
          }
        }
      }
      put :update, nokogiri_request_params
    end
  end

  describe "new" do
    it "should create new Component object with component_type set to item" do
      mock_item = Component.new #mock("component")
      mock_item.expects(:pid).returns("_ITEMID_").at_least_once
      Component.expects(:new).returns(mock_item)
      mock_item.expects(:save)
      xhr :post, :new, :content_type=>"component", :item_id=>"_ITEMID_", :label=>"item", :subcollection_id=>"_SCID_"
      mock_item.component_type.should have_text("item")
#      mock_item.item_id.should == "_ITEMID_"
    end

    it "should create new Component object with component_type set to subcollection" do
      mock_sc = Component.new #mock("component")
      mock_sc.expects(:pid).returns("_SCID_").at_least_once
      Component.expects(:new).returns(mock_sc)
      mock_sc.expects(:save)
      xhr :post, :new, :content_type=>"component", :subcollection_id=>"_SCID_", :label=>"subcollection", :collection_id=>"_CID_"
      mock_sc.component_type.should have_text("subcollection")
#      mock_sc.subcollection_id.should == "_SCID_"
    end
  end

  describe "show" do
    it "should retreive datastream content for given datastream id" do
      simple_request_params = { 
       "id" => "_PID_",
       "field_id"=>"title",
       "datastream"=>"descMetadata",       
       "field"=>"dsc_0_collection_0_did_0_unittitle_0_unitdate"
      }
      mock_component = mock("component")
      mock_component.stubs(:retrieve_af_model).returns("component")
      mock_component.stubs(:pid).returns("_PID_")
      mock_doc = SolrDocument.new({"dsc_0_collection_0_did_0_unittitle_0_unitdate_t"=>["_TITLE_"]})
      controller.expects(:get_solr_response_for_doc_id).returns(["solr_response",mock_doc])
      put :show, simple_request_params
      response.should have_text("_TITLE_")
    end
  end
  describe "destroy" do
    it "should delete the Component identified by pid" do
      mock_obj = mock("component", :delete)
      ActiveFedora::Base.expects(:load_instance).with("__PID__").returns(mock_obj)
      delete(:destroy, :id => "__PID__")
    end
  end

end

