require "hydra"

#Currency
class Collection < ActiveFedora::Base
  
  include Hydra::ModelMethods

  has_bidirectional_relationship "members", :has_member, :is_member_of
  #reusing parts here because has_subset taken already
  has_bidirectional_relationship "highlighted", :has_part, :is_part_of
  has_bidirectional_relationship "subsets", :has_subset, :is_subset_of
  has_bidirectional_relationship  "descriptions",   :has_description, :is_description_of
    
  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 
  
  # Uses the Hydra MODS Article profile for tracking most of the descriptive metadata
  has_metadata :name => "descMetadata", :type => EadXml

  # A datastream to hold browseable facet list
  has_metadata :name => "filters", :type => ActiveFedora::MetadataDatastream do |m|
    m.field "facets", :string
    m.field "query", :string
    m.field "tags", :string
  end

  def intialize(attrs = {})
    super
    @facet_subset_map = {}
    load_facet_subset_map
  end

  attr_accessor :facet_members

  def load_facet_subsets_map
    @facet_subsets_map = {}
    subsets.each do |subset|
      if subset.respond_to? :selected_facets
        @facet_subsets_map.merge!({subset.selected_facets=>subset})
      end
    end
    @facet_subsets_map
  end

  def facet_subsets_map
    load_facet_subsets_map if @facet_subsets_map.nil? || @relationships_are_dirty || rels_ext.relationships_are_dirty
    @facet_subsets_map
  end

  def facet_members(refresh=false)
    if facet_members.nil? || refresh
      facet_members = {}
      browse_facets.each do |facet|
        facet_members << facet
      end
      members.each do |member|
        if member.responds_to? :facets
          #map facet value to member item
          facet_members[facet].merge!({member.facets[facet]=>member})
        end
      end
    end
    facet_members
  end

  def browse_facets
    datastreams["filters"].fields[:facets][:values]
  end
  
  def insert_new_node(type, opts)
    ds = self.datastreams_in_memory["descMetadata"]
    node, index = ds.insert_node(type, opts)
    return node, index
  end

  def description_list
    descriptions.any? ? descriptions : nil
  end
  
  def remove_image(type, index)
    ds = self.datastreams_in_memory["descMetadata"]
    result = ds.remove_node(type,index)
    return result
  end
  
end
