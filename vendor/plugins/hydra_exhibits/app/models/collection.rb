require "hydra"
#Currency
class Collection < ActiveFedora::Base
  
  include Hydra::ModelMethods

  has_bidirectional_relationship "items", :has_member, :is_member_of #, :type=>Item

  has_bidirectional_relationship  "description",   :has_description, :is_description_of
    
  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 
  
  # Uses the Hydra MODS Article profile for tracking most of the descriptive metadata
  has_metadata :name => "descMetadata", :type => Hydra::EadXml

  # A place to put extra metadata values
  has_metadata :name => "properties", :type => ActiveFedora::MetadataDatastream do |m|
  end
  
  def insert_new_node(type, opts)
    ds = self.datastreams_in_memory["descMetadata"]
    node, index = ds.insert_node(type, opts)
    return node, index
  end

  def description_list
    description.any? ? description : nil
  end
  
end
