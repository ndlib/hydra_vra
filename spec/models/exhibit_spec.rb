require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"
require "nokogiri"

describe Exhibit do
  
  before(:each) do
    Fedora::Repository.stubs(:instance).returns(stub_everything())
    @exhibit = Exhibit.new
  end

  describe "#exhibit_title" do
    it "should return empty string if no exhibit title defined" do
      @exhibit.exhibit_title.should == ""
    end

    it "should return the exhibit title from descMetadata datastream if exhibit_title defined" do
      @exhibit.update_indexed_attributes({:exhibit_title=>{0=>"My title"}})
      @exhibit.exhibit_title.should == "My title"
    end
  end

  describe "#build_members_query" do
    it "should return empty string if no members defined" do
      @exhibit.build_members_query.should == ""
    end

    it "should return a query string with delimiter AND and prefix _query_:" do
      @exhibit.update_indexed_attributes({:query=>{0=>"id_t:RBSC-CURRENCY"}})
      @exhibit.build_members_query.should == "_query_:\"id_t:RBSC-CURRENCY\""
      @exhibit.update_indexed_attributes({:query=>{1=>"myfield:value"}})
      @exhibit.build_members_query.should == "_query_:\"id_t:RBSC-CURRENCY\" AND _query_:\"myfield:value\""
    end
  end

  describe "#query_values" do
    it "should return an array of solr query queries that will be used for filter queries" do
      @exhibit.update_indexed_attributes({:query=>{0=>"id_t:RBSC-CURRENCY"}})
      @exhibit.query_values.should == ["id_t:RBSC-CURRENCY"]
      @exhibit.update_indexed_attributes({:query=>{1=>"dsc_0_collection_0_did_0_unittitle_0_imprint_0_publisher_t:Connecticut"}})
      @exhibit.query_values.should == ["id_t:RBSC-CURRENCY","dsc_0_collection_0_did_0_unittitle_0_imprint_0_publisher_t:Connecticut"]
    end
  end

  describe "load_facet_subsets_map" do
    it "should initialize facet_subsets_map to have selected facet mapped to subset if exist" do
      @exhibit.facet_subsets_map.should == {}
      subset1 = SubExhibit.new
      subset1.selected_facets_append({:my_facet1=>["my_value1"]})
      subset1.selected_facets.should == {:my_facet1=>"my_value1"}
      subset2 = SubExhibit.new
      subset2.selected_facets_append({:my_facet1=>["my_value1"],:my_facet2=>["my_value2"]})
      @exhibit.expects(:subsets).returns([subset1,subset2])
      @exhibit.load_facet_subsets_map
      @exhibit.facet_subsets_map.should == {{:my_facet1=>"my_value1"}=>subset1,{:my_facet1=>"my_value1",:my_facet2=>"my_value2"}=>subset2}
    end
  end

  describe "facet_subsets_map" do
    it "should call load_facet_subsets_map if facet_subsets_map is nil" do
      exhibit = Exhibit.new
      exhibit.expects(:load_facet_subsets_map).once()
      exhibit.facet_subsets_map
    end

    it "should initialize facet_subsets_map to empty hash if no already subsets exist" do
      @exhibit.facet_subsets_map.should == {}
    end

    it "should call load_facet_subsets_map if relationships are dirty, but otherwise no if already initialized" do
      @exhibit.facet_subsets_map.should == {}
      @exhibit.expects(:load_facet_subsets_map).once()
      #should not execute load here
      @exhibit.facet_subsets_map
      @subexhibt = SubExhibit.new
      @exhibit.subsets_append(@subexhibit)
      #should execute load now that relationships updated
      @exhibit.facet_subsets_map
    end
  end

  describe "browse_facets" do
    it "should return array of facets used in browsing" do
      @exhibit.update_indexed_attributes({:facets=>{0=>"my_facet_1",1=>"my_facet_2"}})
      @exhibit.browse_facets.should == ["my_facet_1","my_facet_2"]
    end
  end

  describe "description_list" do
    it "should return nil if no descriptions defined" do
      @exhibit.description_list.should == nil
    end

    it "should return array of descriptions if any defined" do
      description = Description.new
      @exhibit.expects(:descriptions).returns([description]).twice()
      @exhibit.description_list.should == [description]
    end
  end
end
