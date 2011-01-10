require "hydra"
#Currency
class Component < ActiveFedora::Base
  
  include Hydra::ModelMethods

  has_bidirectional_relationship "member_of", :is_member_of, :has_member
  has_bidirectional_relationship "members", :has_member, :is_member_of
  has_bidirectional_relationship "highlighted", :has_subset, :is_subset_of
  has_bidirectional_relationship "descriptions",   :has_description, :is_description_of
  #just use parts relationship instead?
  has_bidirectional_relationship "page", :has_part_of, :is_part_of
 
  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 
  
  # Uses the Hydra MODS Article profile for tracking most of the descriptive metadata
  has_metadata :name => "descMetadata", :type => EadXml
  
  # A place to put extra metadata values
  has_metadata :name => "properties", :type => ActiveFedora::MetadataDatastream do |m|
    m.field "subcollection_id", :string
    m.field "item_id", :string
  end

  def subcollection_id
    return @subcollection_id if (defined? @subcollection_id)
    values = self.fields[:subcollection_id][:values]
    @subcollection_id = values.any? ? values.first : ""
  end
  def item_id
    return @item_id if (defined? @item_id)
    values = self.fields[:item_id][:values]
    @item_id = values.any? ? values.first : ""
  end
  
  def insert_new_node(type, opts)
    ds = self.datastreams_in_memory["descMetadata"]
    node, index = ds.insert_node(type, opts)
    return node, index
  end
  
  def get_component_level
    return @component_level
  end
  
end
