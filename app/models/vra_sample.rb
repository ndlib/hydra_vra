require "hydra"

class VraSample < ActiveFedora::Base
  
  include Hydra::ModelMethods

  has_relationship "images", :is_part_of, :inbound => true

  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 
  
  # Uses the Hydra MODS Article profile for tracking most of the descriptive metadata
  has_metadata :name => "descMetadata", :type => Hydra::VraXml

  # A place to put extra metadata values
  has_metadata :name => "properties", :type => ActiveFedora::MetadataDatastream do |m|
    m.field 'agent', :string
    m.field 'description', :string
  end
  
end
