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
      #pending "too rigid.  fails on unimportant inconsistencies"
      node = VraXml.agent_template
      node.should be_kind_of(Nokogiri::XML::Element)
      node.to_xml.sort.should == ["    <earliestDate/>\n", "    <latestDate/>\n", "  </dates>\n", "  <culture/>\n", "  <dates type=\"life\">\n", "  <name type=\"personal\" vocab=\"ULAN\" refid=\"\"/>\n", "  <role/>\n", "</agent>", "<agent>\n"]
    end
  end

  describe "#image_template" do
    it "should generate a new image node" do
      #pending "too rigid.  fails on unimportant inconsistencies"
      node = VraXml.image_template
      node.should be_kind_of(Nokogiri::XML::Element)
      node.to_xml.sort.should == ["      <name/>\n", "      <refid/>\n", "      <term/>\n", "    </source>\n", "    </subject>\n", "    <description/>\n", "    <display/>\n", "    <display/>\n", "    <display/>\n", "    <display/>\n", "    <display/>\n", "    <display/>\n", "    <display/>\n", "    <display/>\n", "    <display/>\n", "    <display/>\n", "    <display/>\n", "    <location refid=\"\"/>\n", "    <measurementsSet type=\"resoultion\" unit=\"ppi\"/>\n", "    <relation type=\"\" source=\"\" ref_id=\"\"/>\n", "    <rights/>\n", "    <source>\n", "    <subject>\n", "    <technique/>\n", "    <title type=\"\"/>\n", "    <worktype vocab=\"\" refid=\"\"/>\n", "  </dateSet>\n", "  </descriptionSet>\n", "  </locationSet>\n", "  </measurementsSet>\n", "  </relationSet>\n", "  </rightsSet>\n", "  </sourceSet>\n", "  </subjectSet>\n", "  </techniqueSet>\n", "  </titleSet>\n", "  </worktypeSet>\n", "  <dateSet>\n", "  <descriptionSet>\n", "  <locationSet>\n", "  <measurementsSet>\n", "  <relationSet>\n", "  <rightsSet>\n", "  <sourceSet>\n", "  <subjectSet>\n", "  <techniqueSet>\n", "  <titleSet>\n", "  <worktypeSet>\n", "</image>", "<image source=\"\" id=\"\" refid=\"\">\n"]
    end
  end

  describe "#xml_template" do
    it "should return an empty xml document" do
      pending "too rigid.  fails on unimportant inconsistencies"
      correct_template = "<?xml version=\"1.0\"?>\n<mods xmlns:xlink=\"http://www.w3.org/1999/xlink\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"http://www.loc.gov/mods/v3\" version=\"3.3\" xsi:schemaLocation=\"http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd\">\n  <titleInfo>\n    <title/>\n  </titleInfo>\n  <name type=\"personal\">\n    <namePart type=\"given\"/>\n    <namePart type=\"family\"/>\n    <affiliation/>\n    <role>\n      <roleTerm type=\"text\" authority=\"marcrelator\"/>\n    </role>\n  </name>\n  <name type=\"corporate\">\n    <namePart/>\n    <role>\n      <roleTerm type=\"text\" authority=\"marcrelator\"/>\n    </role>\n  </name>\n  <name type=\"conference\">\n    <namePart/>\n    <role>\n      <roleTerm type=\"text\" authority=\"marcrelator\"/>\n    </role>\n  </name>\n  <typeOfResource/>\n  <genre authority=\"marcgt\"/>\n  <language>\n    <languageTerm type=\"code\" authority=\"iso639-2b\"/>\n  </language>\n  <abstract/>\n  <subject>\n    <topic/>\n  </subject>\n  <relatedItem type=\"host\">\n    <titleInfo>\n      <title/>\n    </titleInfo>\n    <identifier type=\"issn\"/>\n    <originInfo>\n      <publisher/>\n      <dateIssued/>\n    </originInfo>\n    <part>\n      <detail type=\"volume\">\n        <number/>\n      </detail>\n      <detail type=\"number\">\n        <number/>\n      </detail>\n      <extent unit=\"page\">\n        <start/>\n        <end/>\n      </extent>\n      <date/>\n    </part>\n  </relatedItem>\n  <location>\n    <url/>\n  </location>\n</mods>\n"
      provisional_template = "<image source=\"\" refid=\"\" id=\"\">\n  <dateSet>\n    <display/>\n  </dateSet>\n  <measurementsSet>\n    <display/>\n    <measurementsSet type=\"resoultion\" unit=\"ppi\"/>\n  </measurementsSet>\n  <techniqueSet>\n    <display/>\n    <technique/>\n  </techniqueSet>\n  <descriptionSet>\n    <display/>\n    <description/>\n  </descriptionSet>\n  <locationSet>\n    <display/>\n    <location refid=\"\"/>\n  </locationSet>\n  <relationSet>\n    <display/>\n    <relation type=\"\" ref_id=\"\" source=\"\"/>\n  </relationSet>\n  <rightsSet>\n    <display/>\n    <rights/>\n  </rightsSet>\n  <subjectSet>\n    <display/>\n    <subject>\n      <term/>\n    </subject>\n  </subjectSet>\n  <titleSet>\n    <display/>\n    <title type=\"\"/>\n  </titleSet>\n  <sourceSet>\n    <display/>\n    <source>\n      <name/>\n      <refid/>\n    </source>\n  </sourceSet>\n  <worktypeSet>\n    <display/>\n    <worktype refid=\"\" vocab=\"\"/>\n  </worktypeSet>\n</image>"
      VraXml.xml_template.to_xml.should == provisional_template
    end
  end

  describe "insert_node" do
    it "should generate a new agent into the current xml, treating strings and symbols equally to indicate type and mark the datastream as dirty" do
      @vra_doc.find_by_terms(:work,:agent_set, :agent).length.should == 1
      @vra_doc.dirty?.should be_false
      node, index = @vra_doc.insert_node("agent")
      @vra_doc.dirty?.should be_true

      @vra_doc.find_by_terms(:work,:agent_set, :agent).length.should == 2
      node.to_xml.should == VraXml.agent_template.to_xml
      index.should == 1

      node, index = @vra_doc.insert_node("agent")
      @vra_doc.find_by_terms(:work,:agent_set, :agent).length.should == 3
      index.should == 2
    end
    it "should support adding new inage set" do
     @vra_doc.find_by_terms(:image).length.should == 1
      @vra_doc.dirty?.should be_false
      node, index = @vra_doc.insert_node("image_tag")
      @vra_doc.dirty?.should be_true

      @vra_doc.find_by_terms(:image).length.should == 2
      node.to_xml.should == VraXml.image_template.to_xml
      index.should == 1

      node, index = @vra_doc.insert_node("image_tag")
      @vra_doc.find_by_terms(:image).length.should == 3
      index.should == 2
    end
  end

  describe "remove_node" do
    it "should remove the image node from the xml and then mark the datastream as dirty" do
      @vra_doc.find_by_terms(:image).length.should == 1
      result = @vra_doc.remove_node("image", "0")
      @vra_doc.find_by_terms(:image).length.should == 0
      @vra_doc.should be_dirty
    end
    it "should remove the agent node from the xml and then mark the datastream as dirty" do
      @vra_doc.find_by_terms(:work,:agent_set, :agent).length.should == 1
      result = @vra_doc.remove_node("agent", "0")
      @vra_doc.find_by_terms(:work,:agent_set, :agent).length.should == 0
      @vra_doc.should be_dirty
    end
  end

  describe ".update_indexed_attributes" do
    it "should work for all of the fields we want to display" do
      [ [:work, :agent_set],[:work, :agent_set,:agent], [:work, :agent_set,:agent,:name], [:work, :agent_set,{:agent=>0},:name]] .each do |pointer|
        test_val = "#{pointer.last.to_s} value"
        @vra_doc.update_indexed_attributes( {pointer=>{"0"=>test_val}} )
        @vra_doc.get_values(pointer).first.should == test_val
      end
    end
    it "should work for fields that are attributes" do
      pointer = [:work, :work_id]
      test_val = "#{pointer.last.to_s} value"
      @vra_doc.update_indexed_attributes( {[:work, :work_id]=>{"0"=>test_val}} )
      @vra_doc.get_values(pointer).first.should == test_val
    end

  end
=begin  describe "apply_depositor_metadata" do
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