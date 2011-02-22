require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
class FakeComponentsController
  include ComponentsControllerHelper
end
def helper
  @fake_controller
end
describe ComponentsControllerHelper do
  before(:all) do
    @fake_controller = FakeComponentsController.new
  end
  describe "create_and_save_component" do
    it "should create new Component object and set the descMetadata datastream to item_template." do
      mock_component = Component.new
      Component.expects(:new).returns(mock_component)
      helper.expects(:apply_depositor_metadata)
      helper.expects(:set_collection_type)
#      mock_collection.expects(:datastreams).expects(:ng_xml).returns(EadXml.collection_template.to_xml)
      mock_component.expects(:save)
      helper.create_and_save_component("item", "component", "_PARENTID_")
      expected_result = XmlSimple.xml_in(mock_component.datastreams["descMetadata"].to_xml)
      result = EadXml.item_template.to_xml
      XmlSimple.xml_in(result).should == expected_result
    end
  end
end

