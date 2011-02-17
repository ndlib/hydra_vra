require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

#

describe DescriptionsController do

  describe "update" do
    it "should update datastream and save successfully" do
      mock_description = mock("description")
      Description.expects(:load_instance).with("_PID_").returns(mock_description)
      simple_request_params = { "name"=>"asset[DESCRIPTIONDATASTREAM1][descriptiondatastream]",
       "id" => "test:assetTest",
       "field_id"=>"base_id-text",
       "datastream"=>"descriptiondatastream",
       "load_datastream"=>"true",
       "asset"=>{"DESCRIPTIONDATASTREAM1"=>{"descriptiondatastream"=>"update datastream"}}
      }
      mock_description.expects(:update_named_datastream).with("descriptiondatastream",{:dsid=>"DESCRIPTIONDATASTREAM1", :file=>"update datastream", :label=>"test description", :mimeType=>"text/html"}).returns("updated")
      mock_description.expects(:save)      
      put :update, {:description_id=>"_PID_"}.merge(simple_request_params)
    end

    it "should update descMetadata summary attribute and save successfully" do
      mock_description = mock("description")
      Description.expects(:load_instance).with("_PID_").returns(mock_description)
      simple_request_params = {"datastream"=>"descMetadata",
          "id"=>"test:assetTest",
          "load_datastream"=>"false",
          "asset"=>{"descMetadata"=>{"summary"=>{"0"=>"Summary update"}}}
          }
      mock_description.expects(:update_indexed_attributes).with({"summary"=>{"0"=>"Summary update"}}, {:datastreams=>"descMetadata"}).returns({"summary"=>{"0"=>"Summary Update"}})
      mock_description.expects(:save)
      put :update, {:description_id=>"_PID_"}.merge(simple_request_params)
    end
  end

  describe "show" do
    it "should retreive datastream content for given datastream id" do
      mock_description = mock("description")
      mock_description.stubs(:retrieve_af_model).returns("Description") 
      Description.expects(:load_instance).with("_PID_").returns(mock_description)
      simple_request_params = { "name"=>"asset[DESCRIPTIONDATASTREAM1][descriptiondatastream]",
       "id" => "test:assetTest",
       "field_id"=>"base_id-text",
       "datastream"=>"descriptiondatastream",
       "load_datastream"=>"true",
       "asset"=>{"DESCRIPTIONDATASTREAM1"=>{"descriptiondatastream"=>"update datastream"}}       
      }
      mock_description.stubs(:pid).returns("_PID_")
      mock_description.expects(:content).returns("content of the datastream")
      put :show, {:description_id=>"_PID_"}.merge(simple_request_params)
    end

    it "should retreive field value when load_datastream is false" do
      mock_description = mock("description")
      mock_description.stubs(:retrieve_af_model).returns("description")
      simple_request_params = { "name"=>"asset[DESCRIPTIONDATASTREAM1][descriptiondatastream]",
       "id" => "test:assetTest",
       "field_id"=>"summary_0-text",
       "datastream"=>"descMetadata",       
       "field"=>"summary"       
      }
      mock_description.stubs(:pid).returns("_PID_")
      mock_doc = SolrDocument.new({"summary_t"=>["test summary value"]})
      controller.expects(:get_solr_response_for_doc_id).with("_PID_").returns(["solr_response",mock_doc])
      put :show, {:description_id=>"_PID_"}.merge(simple_request_params)      
      response.should have_text("test summary value")
    end
  end      

  describe "add" do
    it "Create a description object, add content to its datastreams, add the asset to its relationships, and save both objects" do
      simple_request_params = {"id"=>"test:asset",
         "datastream"=>"descriptiondatastream",
          "asset"=>{"0"=>{"descriptiondatastream"=>"this is the content of the datastream"}}
          }
      mock_description = mock("Description", :save)
      Description.expects(:new).returns(mock_description)
      mime_type = "text/html"
      mock_description.expects(:descriptiondatastream_append).with(:file=>"this is the content of the datastream", :label=>"test", :mimeType=>mime_type)
      mock_ds = Hash.new("datastreams_in_memory"=>{"rightsMetadata"=> {"person"=>{"person1"=>"read"}}})
      mock_rights_ds = mock_ds["rightsMetadata"]
      mock_description.expects(:datastreams_in_memory).returns(mock_ds)
      mock_rights_ds.expects(:update_indexed_attributes).with([:read_access, :person]=>"public").returns({"read_access"=>{"person"=>"public"}})
      mock_description.stubs(:pid).returns("test:description_pid")
      mock_description.expects(:save)
      mock_asset = mock("asset")
      ActiveFedora::Base.expects(:load_instance).with("test:asset").returns(mock_asset)
      ActiveFedora::ContentModel.expects(:known_models_for).with(mock_asset ).returns([ActiveFedora::Base])
      ActiveFedora::Base.expects(:load_instance).with("test:asset").returns(mock_asset)
      mock_description.expects(:description_of_append).with(mock_asset)
      mock_description.expects(:save)
      mock_asset.expects(:save)
      ActiveFedora::Base.expects(:load_instance).with("test:asset").returns(mock_asset)
      Description.expects(:load_instance).with("test:description_pid").returns(mock_description)
      mock_asset.stubs(:descriptions_inbound_ids).returns(["test:description_pid"])
      put :add, simple_request_params
    end

    it "If description title is provided add it to descMetadata title value" do
      simple_request_params = {"id"=>"test:asset",
         "datastream"=>"descriptiondatastream",
         "description_title"=>"add description title",
         "asset"=>{"0"=>{"descriptiondatastream"=>"this is the content of the datastream"}}
          }
      mock_description = mock("Description", :save)
      Description.expects(:new).returns(mock_description)
      mime_type = "text/html"
      mock_description.expects(:descriptiondatastream_append).with(:file=>"this is the content of the datastream", :label=>"test", :mimeType=>mime_type)
      mock_ds = Hash.new("datastreams_in_memory"=>{"rightsMetadata"=> {"person"=>{"person1"=>"read"}}})
      mock_rights_ds = mock_ds["rightsMetadata"]
      mock_description.expects(:datastreams_in_memory).returns(mock_ds)
      mock_rights_ds.expects(:update_indexed_attributes).with([:read_access, :person]=>"public").returns({"read_access"=>{"person"=>"public"}})
      mock_description.stubs(:pid).returns("test:description_pid")
      mock_description.expects(:save)
      mock_asset = mock("asset")
      ActiveFedora::Base.expects(:load_instance).with("test:asset").returns(mock_asset)
      ActiveFedora::ContentModel.expects(:known_models_for).with(mock_asset ).returns([ActiveFedora::Base])
      ActiveFedora::Base.expects(:load_instance).with("test:asset").returns(mock_asset)
      mock_description.expects(:description_of_append).with(mock_asset)
      mock_description.expects(:save)
      mock_asset.expects(:save)
      ActiveFedora::Base.expects(:load_instance).with("test:asset").returns(mock_asset)
      Description.expects(:load_instance).with("test:description_pid").returns(mock_description)
      mock_asset.stubs(:descriptions_inbound_ids).returns(["test:description_pid"])
      mock_description.expects(:update_indexed_attributes).with(:title=>{"0"=>simple_request_params["description_title"]}).returns({"title"=>{"0"=>"add description title"}})
      mock_description.expects(:save)
      put :add, simple_request_params
    end
  end

  describe "update_title" do
    it "should update description title and save successfully" do
      mock_description = mock("description")
      Description.expects(:load_instance).with("_PID_").returns(mock_description)
      simple_request_params = { "description_title"=>"update description title",
          "datastream_name"=>"descMetadata",
          "id"=>"test:assetTest"
      }
      mock_description.expects(:update_indexed_attributes).with(:title=>{"0"=>"update description title"}).returns({"title"=>{"0"=>"update description title"}})
      mock_description.expects(:save)
      put :update_title, {:description_id=>"_PID_"}.merge(simple_request_params)
    end
  end
  
  describe "destroy" do
    it "should delete the asset identified by pid" do
      mock_obj = mock("description", :delete)
      Description.expects(:load_instance).with("__PID__").returns(mock_obj)
      delete(:destroy, :id => "__PID__", :asset_content_type=>"test",:asset_id=>"test:assetID")
    end

    it "should delete the asset identified by pid" do
      mock_obj = mock("description", :delete)
      Description.expects(:load_instance).with("__PID__").returns(mock_obj)
      delete(:destroy, :id => "__PID__", :asset_content_type=>"test",:asset_id=>"test:assetID")
    end    
  end

end
