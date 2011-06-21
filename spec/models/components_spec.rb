require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"
require "nokogiri"
require "hydra"

describe Component do

  before(:each) do
    Fedora::Repository.stubs(:instance).returns(stub_everything())
    @component = Component.new
    @component2 = Component.new
  end

  describe "#id" do
    it "should return pid if id is called" do
      @component.id.should == @component.pid
    end
  end

  #describe "#subcollection_id" do
  #  it "should return empty string if the component object is item and not subcollection" do
  #    @component.subcollection_id.should == ""
  #  end
  #
  #  it "should return string containing subcollection id" do
  #    @component.update_indexed_attributes({:subcollection_id=>{0=>"1"}})
  #    @component.subcollection_id.should == "1"
  #  end
  #end

  #describe "#item_id" do
  #  it "should return empty string if the component object is subcollection and not item" do
  #    @component.item_id.should == ""
  #  end
  #
  #  it "should return string containing item id" do
  #    @component.update_indexed_attributes({:item_id=>{0=>"1"}})
  #    @component.item_id.should == "1"
  #  end
  #end

  describe "#item_title" do
    it "should return empty string if no title defined" do
      @component.item_title.should == ""
    end

    it "should return title" do
      @component.update_indexed_attributes({[:item, :did, :unittitle, :unittitle_content]=>{0=>"Two Shillings, Six Pence"}})
      @component.item_title.should == "Two Shillings, Six Pence"
    end
  end

  describe "#sub_collection_title" do
    it "should return empty string if no title defined" do
      @component.sub_collection_title.should == ""
    end

    it "should return subcollection title" do
      @component.update_indexed_attributes({[:dsc, :collection, :did, :unittitle, :unittitle_content]=>{0=>"March 1, 1780"}})
      @component.sub_collection_title.should == "March 1, 1780"
    end
  end

  describe "#title" do
    it "should return empty string if no title defined" do
      @component.title.should == ""
    end

    it "should return subcollection title" do
      @component.update_indexed_attributes({[:dsc, :collection, :did, :unittitle, :unittitle_content]=>{0=>"March 1, 1780"}})
      @component.title.should == "March 1, 1780"
    end

    it "should return item title" do
      @component.update_indexed_attributes({[:item, :did, :unittitle, :unittitle_content]=>{0=>"Two Shillings, Six Pence"}})
      @component.title.should == "Two Shillings, Six Pence"
    end
  end

  describe "#main_page" do
    it "should return empty string if no main_page defined" do
      @component.main_page.should == ""
    end

    it "should return string of main_page" do
      @component.update_indexed_attributes({:main_page=>{0=>"RBSC-CURRENCY:800"}})
      @component.main_page.should == "RBSC-CURRENCY:800"
    end
  end

  #describe "#list_childern" do
  #  it "should return an array of child page objects" do
  #    com = Component.new
  #    pg1 = Page.new
  #    pg1.expects(:pid).returns("1100")
  #    pg2 = Page.new
  #    pg2.expects(:pid).returns("1200")
  #    com.expects(:page).returns([pg1,pg2]) #(:inbound_relationships).returns({:is_part_of=>[pg1,pg2]})
  #    Component.expects(:load_instance_from_solr).returns(com)
  #    Page.expects(:load_instance_from_solr).with("1100").returns(pg1)
  #    Page.expects(:load_instance_from_solr).with("1200").returns(pg2)
  #    com.list_childern("1000","item")
  #  end

  #  it "should return an array of child item objects" do
  #    com = Component.new
  #    item1 = Component.new
  #    item1.expects(:pid).returns("1001")
  #    item2 = Component.new
  #    item2.expects(:pid).returns("1002")
  #    item3 = Component.new
  #    item3.expects(:pid).returns("1003")
  #    item4 = Component.new
  #    item4.expects(:pid).returns("1004")
  #    com.expects(:members).returns([item1,item2,item3,item4])
  #    Component.expects(:load_instance_from_solr).returns(com)
  #    Component.expects(:load_instance_from_solr).with("1001").returns(item1)
  #    Component.expects(:load_instance_from_solr).with("1002").returns(item2)
  #    Component.expects(:load_instance_from_solr).with("1003").returns(item3)
  #    Component.expects(:load_instance_from_solr).with("1004").returns(item4)
  #    com.list_childern("100", "subcollection")
  #  end
  #end

  describe "#has_value_for" do
    it "should return false if no value present for the term specified" do
      @component.has_value_for("descMetadata", [:item, :did, :unittitle, :unittitle_content]).should == false
    end

    it "should return true if value present for the term specified" do
      @component.update_indexed_attributes({[:item, :did, :unittitle, :unittitle_content]=>{0=>"Two Shillings, Six Pence"}})
      @component.has_value_for("descMetadata", [:item, :did, :unittitle, :unittitle_content]).should == true
    end
  end

  describe "#get_type_from_datastream" do
    it "should return Collection when term containing collection is fed as input" do
      @component.update_indexed_attributes({[:dsc, :collection, :did, :unittitle, :unittitle_content]=>{0=>"March 1, 1780"}})
      @component.get_type_from_datastream.should == :collection
    end

    it "should return Item when term containing item is fed as input" do
      @component.update_indexed_attributes({[:item, :did, :unittitle, :unittitle_content]=>{0=>"Two Shillings, Six Pence"}})
      @component.get_type_from_datastream.should == :item
    end
  end

  describe "#insert_new_node" do
    it "should return xml string with two daoloc elements" do
      @component.datastreams["descMetadata"].ng_xml = EadXml.item_template
      @component.insert_new_node("image",{})
      expected_result = XmlSimple.xml_in("<c02 xmlns:xlink=\"http://www.w3.org/1999/xlink\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"currency-collection\">\n  <did>\n    <unitid/>\n    <origination>\n      <persname role=\"signer\" normal=\"\"/>\n    </origination>\n    <unittitle label=\"\">\n      <num type=\"serial\"/>\n    </unittitle>\n    <physdesc>\n      <dimensions/>\n    </physdesc>\n  </did>\n  <scopecontent/>\n  <odd/>\n  <controlaccess>\n    <genreform/>\n  </controlaccess>\n  <acqinfo/>\n  <daogrp>\n    <daoloc href=\"\"/>\n    <daoloc href=\"\"/>\n  </daogrp>\n</c02>")
      XmlSimple.xml_in(@component.datastreams["descMetadata"].to_xml).should == expected_result
    end
  end

  describe "#remove_image" do
    it "should return xml string with no daoloc elements" do
      @component.datastreams["descMetadata"].ng_xml = EadXml.item_template
      @component.remove_image("image",0)
      expected_result = XmlSimple.xml_in("<c02 xmlns:xlink=\"http://www.w3.org/1999/xlink\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"currency-collection\">\n  <did>\n    <unitid/>\n    <origination>\n      <persname role=\"signer\" normal=\"\"/>\n    </origination>\n    <unittitle label=\"\">\n      <num type=\"serial\"/>\n    </unittitle>\n    <physdesc>\n      <dimensions/>\n    </physdesc>\n  </did>\n  <scopecontent/>\n  <odd/>\n  <controlaccess>\n    <genreform/>\n  </controlaccess>\n  <acqinfo/>\n  <daogrp>\n    </daogrp>\n</c02>")
      XmlSimple.xml_in(@component.datastreams["descMetadata"].to_xml).should == expected_result
    end
  end

#  describe "#to_solr" do
#    it "should return a solrDocument for Component object" do
#      solr_doc = @component.to_solr
#      solr_doc.type.should == Solr::Document
#    end
#  end
   
end
