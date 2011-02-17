require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"
require "nokogiri"

describe Description do
  
  before(:each) do
    Fedora::Repository.stubs(:instance).returns(stub_everything())
    @description = Description.new
    @description.descriptiondatastream_append(:file=>"description datastream content", :label=>"test", :mimeType=>"text/html")    
  end

  describe "#id" do
    it "should return pid if id is called" do
      @description.id.should == @description.pid
    end
  end

  describe "#title" do
    it "should return empty string if no description title defined" do
      @description.title.should == ""
    end
     it "should return the exhibit title from descMetadata datastream if description_title defined" do
      @description.update_indexed_attributes({:title=>{0=>"description title"}})
      @description.title.should == "description title"
    end
  end

  describe "#summary" do
    it "should return empty string if no description summary defined" do
      @description.summary.should == ""
    end
     it "should return the exhibit title from descMetadata datastream if description summary defined" do
      @description.update_indexed_attributes({:summary=>{0=>"description summary"}})
      @description.summary.should == "description summary"
    end
  end

  describe "#style" do
    it "should return empty string if no description page_display defined" do
      @description.style.should == "newpage"
    end
     it "should return the exhibit title from descMetadata datastream if description page_display defined" do
      @description.update_indexed_attributes({:page_display=>{0=>"inline"}})
      @description.style.should == "inline"
    end
  end

  describe "#content" do
    it "should not return nil since description datastream defined" do
      @description.descriptiondatastream.should_not be_nil
    end
    it "should return datastream content from description datastream if defined" do
      @description.descriptiondatastream.first.stubs(:content).returns("description datastream content")
      @description.content.should == "description datastream content"
    end
  end

end
