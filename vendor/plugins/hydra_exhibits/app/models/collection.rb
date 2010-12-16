require "hydra"

#Currency
class Collection < ActiveFedora::Base
  
  include Hydra::ModelMethods

  has_bidirectional_relationship "members", :has_member, :is_member_of
  has_bidirectional_relationship "highlighted", :has_subset, :is_subset_of
  has_bidirectional_relationship  "descriptions",   :has_description, :is_description_of
    
  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 
  
  # Uses the Hydra MODS Article profile for tracking most of the descriptive metadata
  has_metadata :name => "descMetadata", :type => EadXml

  # A place to put extra metadata values
  has_metadata :name => "properties", :type => ActiveFedora::MetadataDatastream do |m|
  end

  attr_accessor :facet_members

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
    ["dsc_0_collection_0_did_0_unittitle_0_imprint_0_publisher_facet"]
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
