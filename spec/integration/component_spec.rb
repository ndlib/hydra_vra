require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"

describe Component do
  before(:each) do
    @comp1 = Component.new
    @comp2 = Component.new
    @comp1.save
    @comp2.save
  end

  after(:each) do
    begin
    @comp1.delete
    rescue
    end
    begin
    @comp2.delete
    rescue
    end
    begin
    @comp3.delete
    rescue
    end
  end

  describe "#is_member_of_component_collection" do
    it "should return array of component objects for is member of component collection relationship" do
      @comp1.member_of_component_collection_append(@comp2)
      @comp1.member_of_component_collection_ids.should == [@comp2.pid]
      @comp1.save
      @comp3 = Component.load_instance(@comp1.pid)
      @comp3.member_of_component_collection_ids.should ==  @comp1.member_of_component_collection_ids
    end
    it "should return array of component objects for component collection member relationship" do
      @comp1.component_collection_members_append(@comp2)
      @comp1.component_collection_members_ids.should == [@comp2.pid]
      @comp1.save
      @comp3 = Component.load_instance(@comp1.pid)
      @comp3.component_collection_members_ids.should ==  @comp1.component_collection_members_ids
    end

    #series
    it "should return array of component objects for is member of series relationship" do
      @comp1.member_of_series_append(@comp2)
      @comp1.member_of_series_ids.should == [@comp2.pid]
      @comp1.save
      @comp3 = Component.load_instance(@comp1.pid)
      @comp3.member_of_series_ids.should ==  @comp1.member_of_series_ids
    end
    it "should return array of component objects for series member relationship" do
      @comp1.series_members_append(@comp2)
      @comp1.series_members_ids.should == [@comp2.pid]
      @comp1.save
      @comp3 = Component.load_instance(@comp1.pid)
      @comp3.series_members_ids.should ==  @comp1.series_members_ids
    end

    #class
    it "should return array of component objects for is member of class relationship" do
      @comp1.member_of_class_append(@comp2)
      @comp1.member_of_class_ids.should == [@comp2.pid]
      @comp1.save
      @comp3 = Component.load_instance(@comp1.pid)
      @comp3.member_of_class_ids.should ==  @comp1.member_of_class_ids
    end
    it "should return array of component objects for class member relationship" do
      @comp1.class_members_append(@comp2)
      @comp1.class_members_ids.should == [@comp2.pid]
      @comp1.save
      @comp3 = Component.load_instance(@comp1.pid)
      @comp3.class_members_ids.should ==  @comp1.class_members_ids
    end
  
    #file
    it "should return array of component objects for is member of file relationship" do
      @comp1.member_of_file_append(@comp2)
      @comp1.member_of_file_ids.should == [@comp2.pid]
      @comp1.save
      @comp3 = Component.load_instance(@comp1.pid)
      @comp3.member_of_file_ids.should ==  @comp1.member_of_file_ids
    end
    it "should return array of component objects for file member relationship" do
      @comp1.file_members_append(@comp2)
      @comp1.file_members_ids.should == [@comp2.pid]
      @comp1.save
      @comp3 = Component.load_instance(@comp1.pid)
      @comp3.file_members_ids.should ==  @comp1.file_members_ids
    end 

    #fonds
    it "should return array of component objects for is member of fonds relationship" do
      @comp1.member_of_fonds_append(@comp2)
      @comp1.member_of_fonds_ids.should == [@comp2.pid]
      @comp1.save
      @comp3 = Component.load_instance(@comp1.pid)
      @comp3.member_of_fonds_ids.should ==  @comp1.member_of_fonds_ids
    end
    it "should return array of component objects for fonds member relationship" do
      @comp1.fonds_members_append(@comp2)
      @comp1.fonds_members_ids.should == [@comp2.pid]
      @comp1.save
      @comp3 = Component.load_instance(@comp1.pid)
      @comp3.fonds_members_ids.should ==  @comp1.fonds_members_ids
    end

    #item
    it "should return array of component objects for is member of item relationship" do
      @comp1.member_of_item_append(@comp2)
      @comp1.member_of_item_ids.should == [@comp2.pid]
      @comp1.save
      @comp3 = Component.load_instance(@comp1.pid)
      @comp3.member_of_item_ids.should ==  @comp1.member_of_item_ids
    end
    it "should return array of component objects for item member relationship" do
      @comp1.item_members_append(@comp2)
      @comp1.item_members_ids.should == [@comp2.pid]
      @comp1.save
      @comp3 = Component.load_instance(@comp1.pid)
      @comp3.item_members_ids.should ==  @comp1.item_members_ids
    end

    #otherlevel
    it "should return array of component objects for is member of otherlevel relationship" do
      @comp1.member_of_otherlevel_append(@comp2)
      @comp1.member_of_otherlevel_ids.should == [@comp2.pid]
      @comp1.save
      @comp3 = Component.load_instance(@comp1.pid)
      @comp3.member_of_otherlevel_ids.should ==  @comp1.member_of_otherlevel_ids
    end
    it "should return array of component objects for otherlevel member relationship" do
      @comp1.otherlevel_members_append(@comp2)
      @comp1.otherlevel_members_ids.should == [@comp2.pid]
      @comp1.save
      @comp3 = Component.load_instance(@comp1.pid)
      @comp3.otherlevel_members_ids.should ==  @comp1.otherlevel_members_ids
    end

    #recordgrp
    it "should return array of component objects for is member of recordgrp relationship" do
      @comp1.member_of_recordgrp_append(@comp2)
      @comp1.member_of_recordgrp_ids.should == [@comp2.pid]
      @comp1.save
      @comp3 = Component.load_instance(@comp1.pid)
      @comp3.member_of_recordgrp_ids.should ==  @comp1.member_of_recordgrp_ids
    end
    it "should return array of component objects for recordgrp member relationship" do
      @comp1.recordgrp_members_append(@comp2)
      @comp1.recordgrp_members_ids.should == [@comp2.pid]
      @comp1.save
      @comp3 = Component.load_instance(@comp1.pid)
      @comp3.recordgrp_members_ids.should ==  @comp1.recordgrp_members_ids
    end

    #subfonds
    it "should return array of component objects for is member of subfonds relationship" do
      @comp1.member_of_subfonds_append(@comp2)
      @comp1.member_of_subfonds_ids.should == [@comp2.pid]
      @comp1.save
      @comp3 = Component.load_instance(@comp1.pid)
      @comp3.member_of_subfonds_ids.should ==  @comp1.member_of_subfonds_ids
    end
    it "should return array of component objects for subfonds member relationship" do
      @comp1.subfonds_members_append(@comp2)
      @comp1.subfonds_members_ids.should == [@comp2.pid]
      @comp1.save
      @comp3 = Component.load_instance(@comp1.pid)
      @comp3.subfonds_members_ids.should ==  @comp1.subfonds_members_ids
    end

    #subgrp
    it "should return array of component objects for is member of subgrp relationship" do
      @comp1.member_of_subgrp_append(@comp2)
      @comp1.member_of_subgrp_ids.should == [@comp2.pid]
      @comp1.save
      @comp3 = Component.load_instance(@comp1.pid)
      @comp3.member_of_subgrp_ids.should ==  @comp1.member_of_subgrp_ids
    end
    it "should return array of component objects for subgrp member relationship" do
      @comp1.subgrp_members_append(@comp2)
      @comp1.subgrp_members_ids.should == [@comp2.pid]
      @comp1.save
      @comp3 = Component.load_instance(@comp1.pid)
      @comp3.subgrp_members_ids.should ==  @comp1.subgrp_members_ids
    end

    #subseries
    it "should return array of component objects for is member of subseries relationship" do
      @comp1.member_of_subseries_append(@comp2)
      @comp1.member_of_subseries_ids.should == [@comp2.pid]
      @comp1.save
      @comp3 = Component.load_instance(@comp1.pid)
      @comp3.member_of_subseries_ids.should ==  @comp1.member_of_subseries_ids
    end
    it "should return array of component objects for subseries member relationship" do
      @comp1.subseries_members_append(@comp2)
      @comp1.subseries_members_ids.should == [@comp2.pid]
      @comp1.save
      @comp3 = Component.load_instance(@comp1.pid)
      @comp3.subseries_members_ids.should ==  @comp1.subseries_members_ids
    end
  end

  
end
