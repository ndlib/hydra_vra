require "hydra"
#Currency
class Item < ActiveFedora::Base
  
  include Hydra::ModelMethods

  has_bidirectional_relationship "pages", :has_part, :is_part_of, :type=>Page
    
  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 
  
  # Uses the Hydra MODS Article profile for tracking most of the descriptive metadata
  has_metadata :name => "descMetadata", :type => Hydra::EadXml

  # A place to put extra metadata values
  has_metadata :name => "properties", :type => ActiveFedora::MetadataDatastream do |m|
  end
  
end
