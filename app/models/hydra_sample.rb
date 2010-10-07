require "hydra"

class HydraSample < ActiveFedora::Base
  
  include Hydra::ModelMethods  

  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 
  
  # Uses the Hydra MODS Article profile for tracking most of the descriptive metadata
  has_metadata :name => "workflow", :type => SampleXml

  # A place to put extra metadata values
  has_metadata :name => "properties", :type => ActiveFedora::MetadataDatastream do |m|
    m.field 'process', :string
    m.field 'workflow', :string
  end
  
end
