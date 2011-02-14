require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"
require "nokogiri"

describe SubExhibit do
  
  before(:each) do
    Fedora::Repository.stubs(:instance).returns(stub_everything())
    @subexhibit = SubExhibit.new
  end

  describe "#id" do
    it "should return pid if id is called" do
      @subexhibit.id.should == @subexhibit.pid
    end
  end

  describe "#selected_facets" do
    it "should return hash of selected facets" do
      @subexhibit.selected_facets_append({:my_facet1=>["my_value1"],:my_facet2=>["my_value2"]})
      @subexhibit.selected_facets.should == {:my_facet1=>"my_value1",:my_facet2=>"my_value2"}
    end
  end

  describe "#selected_facets_append" do
    it "should append to the selected facets hash if call append" do
      @subexhibit.selected_facets.should == {}
      @subexhibit.selected_facets_append({:my_facet2=>["my_value2"]})
      @subexhibit.selected_facets.should == {:my_facet2=>"my_value2"}
      @subexhibit.selected_facets_append({:my_facet1=>["my_value1"]})
      @subexhibit.selected_facets.should == {:my_facet1=>"my_value1",:my_facet2=>"my_value2"}
    end
  end

  describe "#selected_facets_for_params" do
    it "should return selected facets in form blacklight expects with values as an array" do
      @subexhibit.selected_facets.should == {}
      @subexhibit.selected_facets_append({:my_facet2=>["my_value2"]})
      @subexhibit.selected_facets_for_params.should == {:my_facet2=>["my_value2"]}
      @subexhibit.selected_facets_append({:my_facet1=>["my_value1"]})
      @subexhibit.selected_facets_for_params.should == {:my_facet1=>["my_value1"],:my_facet2=>["my_value2"]}
    end
  end

  describe "#description_list" do
    it "should return nil if no descriptions defined" do
      @subexhibit.description_list.should == nil
    end

    it "should return array of descriptions if any defined" do
      description = Description.new
      @subexhibit.expects(:descriptions).returns([description]).twice()
      @subexhibit.description_list.should == [description]
    end
  end
end
