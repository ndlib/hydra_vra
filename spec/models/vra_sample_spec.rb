require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"
require "nokogiri"

describe VraSample do
  
  before(:each) do
    Fedora::Repository.stubs(:instance).returns(stub_everything())
    @vra_doc = VraXml.new
  end

  describe ".new" do
    it "should initialize a new vra document template if no xml is provided" do
      vra_doc = VraXml.new
      vra_doc.ng_xml.to_xml.should == VraXml.xml_template.to_xml
    end
  end

  describe "#agent_template" do
    it "should generate a new agent node" do
      node = VraXml.agent_template
      node.should be_kind_of(Nokogiri::XML::Element)
      node.to_xml.should == "<name type=\"personal\">\n  <namePart type=\"family\"/>\n  <namePart type=\"given\"/>\n  <affiliation/>\n  <role>\n    <roleTerm type=\"text\"/>\n  </role>\n</name>"
    end
  end
  
=begin  describe "insert_agent" do
    it "should generate a new contributor of type (type) into the current xml, treating strings and symbols equally to indicate type, and then mark the datastream as dirty" do
      vra_ds = @building.datastreams_in_memory["descMetadata"]
      vra_ds.expects(:insert_contributor).with("person",{})
      node, index = @building.insert_new_node("agent", {})
    end
  end
  
  describe "remove_agent" do
    it "should remove the corresponding contributor from the xml and then mark the datastream as dirty" do
      vra_ds = @building.datastreams_in_memory["descMetadata"]
      vra_ds.expects(:remove_contributor).with("person","3")
      node, index = @building.remove_contributor("person", "3")
    end
  end
  describe "apply_depositor_metadata" do
    it "should set depositor info in the properties and rightsMetadata datastreams" do
      rights_ds = @building.datastreams_in_memory["rightsMetadata"]
      prop_ds = @building.datastreams_in_memory["properties"]

      node, index = @building.apply_depositor_metadata("Depositor Name")
      
      prop_ds.depositor_values.should == ["Depositor Name"]
      rights_ds.get_values([:edit_access, :person]).should == ["Depositor Name"]
    end
  end
=end
end