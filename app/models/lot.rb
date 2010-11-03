require "hydra"

class Lot < ActiveFedora::Base
  has_relationship "section", :has_part, :type=>Section, :inbound=>true
  has_relationship "building", :has_part,  :type=>Building

  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata

  # Uses the Hydra MODS Article profile for tracking most of the descriptive metadata
  has_metadata :name => "descMetadata", :type => VraXml

end