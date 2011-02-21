require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CollectionsController do

  describe "update" do
    it "should update descMetadata datastream and save successfully" do
      mock_collection = mock("collection")
      Collection.expects(:find).with("_PID_").returns(mock_collection)

      update_method_args = [ { [:ead_header, :filedesc, :titlestmt, :titleproper] => {"0"=>"American Colony"} }, {:datastreams=>"descMetadata"} ]
      mock_collection.expects(:update_indexed_attributes).with( *update_method_args ).returns({"ead_0_ead_header_0_filedesc_0_titlestmt_0_titleproper"=>{"0"=>"American Colony"}})
      mock_collection.expects(:save)

      nokogiri_request_params = {
        "id"=>"_PID_", 
        "content_type"=>"collection",
        "field_selectors"=>{
          "descMetadata"=>{
            "ead_0_ead_header_0_filedesc_0_titlestmt_0_titleproper"=>[:ead_header, :filedesc, :titlestmt, :titleproper]
          }
        }, 
        "asset"=>{
          "descMetadata"=>{
            "ead_0_ead_header_0_filedesc_0_titlestmt_0_titleproper"=>{"0"=>"American Colony"}
          }
        }
      }
      put :update, nokogiri_request_params
    end
  end

#  describe "new" do
#    it "should create new collection object and save successfully" do
#      mock_collection = mock("collection")
#      Collection.expects(:new).with(:namespace=>"RBSC-CURRENCY").returns(mock_collection)
#      mock_collection.expects(:datastreams).with("descMetadata").returns()
#      mock_collection.expects(:save)
#      Collection.expects(:find).with("RBSC-CURRENCY:9999").returns(mock_collection)
#      get :new, :controller => "collections", :content_type => "collection"
#      response.should render_template "collections/_edit_collection"
#    end
#  end
  
end

