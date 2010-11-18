require File.expand_path( File.join( File.dirname(__FILE__), '..','..','spec_helper') )
require "hydra"
class FakeAssetsController
  include MediaShelf::ActiveFedoraHelper
end

def helper
  @fake_controller
end

describe MediaShelf::ActiveFedoraHelper do

  before(:all) do
    @fake_controller = FakeAssetsController.new
  end
  
  describe "retrieve_af_model" do
    it "should return a Model class if the named model has been defined" do
      result = helper.retrieve_af_model("file_asset")
      result.should == FileAsset
      result.superclass.should == ActiveFedora::Base
      result.included_modules.should include(ActiveFedora::Model) 
    end
    it "should accept camel cased OR underscored model name"  
  end

  describe "load_af_instance_from_solr" do
    it "should return an ActiveFedora object given a valid solr doc same as loading from Fedora" do
      pid = "hydrangea:fixture_mods_article1"
      result = ActiveFedora::Base.find_by_solr(pid)
      solr_doc = result.hits.first 
      solr_af_obj = helper.load_af_instance_from_solr(solr_doc)
      fed_af_obj = ActiveFedora::Base.load_instance(pid)
      #check both inbound and outbound match
      fed_af_obj.outbound_relationships.should == solr_af_obj.outbound_relationships
      fed_af_obj.inbound_relationships.should == solr_af_obj.inbound_relationships
    end
  end


  describe "add_named_relationship" do
    before(:each) do
      class FakeModel < ActiveFedora::Base
        has_relationship "rel1", :is_part_of, :type=>FakeModel
        has_relationship "rel2", :has_part
      end
    end
    it "should add relationship if type is defined" do
      @test_object = FakeModel.new
      @test_object.save
      @test_object1 = FakeModel.new
      @test_object1.save
      relationship_name="rel1"
      pid=@test_object1.pid
      helper.add_named_relationship(@test_object,relationship_name,pid)
      puts "Relationships: #{@test_object.named_relationship(relationship_name)}"
      @test_object.named_relationship(relationship_name) == "rel1"
    end
  end
  
end
