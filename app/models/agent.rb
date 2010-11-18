require "hydra"

class Agent < ActiveFedora::Base

  include Hydra::ModelMethods

  has_relationship "images", :is_part_of, :inbound => true
  has_relationship "locations", :has_member

  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata

  # Uses the Hydra MODS Article profile for tracking most of the descriptive metadata
  has_metadata :name => "descMetadata", :type => VraXml

  # A place to put extra metadata values
  has_metadata :name => "properties", :type => ActiveFedora::MetadataDatastream do |m|
    m.field 'agent', :string
    m.field 'description', :string
  end

  # Call insert_contributor on the descMetadata datastream
  def insert_new_node(type, opts)
    ds = self.datastreams_in_memory["descMetadata"]
    node, index = ds.insert_node(type, opts)
    return node, index
  end

end
