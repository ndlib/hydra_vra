require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"
require "nokogiri"
require "hydra"

describe Component do
  before(:each) do
    Fedora::Repository.stubs(:instance).returns(stub_everything())
    @page = Page.new
  end

  describe "#page_id" do
    it "should return empty string if no page_id defined" do
      @page.page_id.should == ""
    end

    it "should return the page_id of the object" do
      @page.update_indexed_attributes({:page_id=>{0=>"1"}})
      @page.page_id.should == "1"
    end
  end

  describe "#name" do
    it "should return empty string if no name defined" do
      @page.name.should == ""
    end

    it "should return the name of the object" do
      @page.update_indexed_attributes({:name=>{0=>"Front_View"}})
      @page.name.should == "Front_View"
    end
  end

  describe "#title" do
    it "should return empty string if no title defined" do
      @page.title.should == ""
    end

    it "should return the title of the object" do
      @page.update_indexed_attributes({:title=>{0=>"C01982028_frnt.jpg"}})
      @page.title.should == "C01982028_frnt.jpg"
    end
  end

end
