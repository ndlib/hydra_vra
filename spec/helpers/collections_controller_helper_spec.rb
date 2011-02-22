require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
class FakeCollectionsController
  include CollectionsControllerHelper
end
def helper
  @fake_controller
end
describe CollectionsControllerHelper do
  before(:all) do
    @fake_controller = FakeCollectionsController.new
  end
  describe "create_and_save_collection" do
    it "should create new Collection object and set the descMetadata datastream to collection_template." do
      mock_collection = Collection.new
      Collection.expects(:new).returns(mock_collection)
      helper.expects(:apply_depositor_metadata)
      helper.expects(:set_collection_type)
#      mock_collection.expects(:datastreams).expects(:ng_xml).returns(EadXml.collection_template.to_xml)
      mock_collection.expects(:save)
      helper.create_and_save_collection("collection")
      expected_result = XmlSimple.xml_in(mock_collection.datastreams["descMetadata"].to_xml)
      result = EadXml.collection_template.to_xml
      XmlSimple.xml_in(result).should == expected_result
    end
  end
end

