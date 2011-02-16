require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"
require "nokogiri"
require "hydra"

describe Component do
  before(:each) do
    Fedora::Repository.stubs(:instance).returns(stub_everything())
    @collection = Collection.new
  end
  
  describe "#title" do
    it "should return empty string if no title defined" do
      @collection.title.should == ""
    end

    it "should return the title of the object" do
      @collection.update_indexed_attributes({[:ead_header, :filedesc, :titlestmt, :titleproper]=>{0=>"American Colonial"}})
      @collection.title.should == "American Colonial"
    end
  end

  describe "description_list" do
    it "should return nil if no descriptions defined" do
      @collection.description_list.should == nil
    end

    it "should return array of descriptions if any defined" do
      description = Description.new
      @collection.expects(:descriptions).returns([description]).twice()
      @collection.description_list.should == [description]
    end
  end

  describe "#list_childern" do
    it "should return an array of child objects" do
      coll = Collection.new
      sc1 = Component.new
      sc1.expects(:pid).returns("201")
      sc2 = Component.new
      sc2.expects(:pid).returns("202")
      sc3 = Component.new
      sc3.expects(:pid).returns("203")
      sc4 = Component.new
      sc4.expects(:pid).returns("204")
      coll.expects(:members).returns([sc1,sc2,sc3,sc4])
      Collection.expects(:load_instance_from_solr).returns(coll)
      Component.expects(:load_instance_from_solr).with("201").returns(sc1)
      Component.expects(:load_instance_from_solr).with("202").returns(sc2)
      Component.expects(:load_instance_from_solr).with("203").returns(sc3)
      Component.expects(:load_instance_from_solr).with("204").returns(sc4)
      coll.list_childern("1", nil)
    end
  end

end
