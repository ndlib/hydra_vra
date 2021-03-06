require "hydra"

class Building < ActiveFedora::Base

  include Hydra::ModelMethods

  has_relationship "images", :is_part_of, :inbound => true
  has_relationship "agents", :has_member, :type=>Agent, :inbound => true
  has_relationship "lot", :has_part, :type=>Lot, :inbound=>true

  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata

  # Uses the Hydra MODS Article profile for tracking most of the descriptive metadata
  has_metadata :name => "descMetadata", :type => VraXml

  # A place to put extra metadata values
  has_metadata :name => "properties", :type => ActiveFedora::MetadataDatastream do |m|
    m.field 'agent', :string
    m.field 'description', :string
  end

  alias_method :id, :pid

  # Call insert_node on the descMetadata datastream
  def insert_new_node(type, opts)
    ds = self.datastreams_in_memory["descMetadata"]
    node, index = ds.insert_node(type, opts)
    return node, index
  end

  # Call remove_agent node on the descMetadata datastream
  def remove_agent(type, index)
    ds = self.datastreams_in_memory["descMetadata"]
    result = ds.remove_node(type,index)
    return result
  end

  def remove_image(type, index)
    ds = self.datastreams_in_memory["descMetadata"]
    result = ds.remove_node(type,index)
    return result
  end

  def lot_list
    lot.any? ? lot : nil
  end

end
