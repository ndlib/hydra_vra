require "hydra"

#Currency
class Collection < ActiveFedora::Base
  
  include Hydra::ModelMethods

  has_bidirectional_relationship "members", :has_member, :is_member_of
  has_bidirectional_relationship  "descriptions",   :has_description, :is_description_of
    
  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 
  
  # Uses the Hydra MODS Article profile for tracking most of the descriptive metadata
  has_metadata :name => "descMetadata", :type => EadXml

  def insert_new_node(type, opts)
    ds = self.datastreams_in_memory["descMetadata"]
    node, index = ds.insert_node(type, opts)
    return node, index
  end

  def remove_image(type, index)
    ds = self.datastreams_in_memory["descMetadata"]
    result = ds.remove_node(type,index)
    return result
  end

  def description_list
    descriptions.any? ? descriptions : nil
  end
  
end
