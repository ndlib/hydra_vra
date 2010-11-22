require "hydra"

class Essay < ActiveFedora::Base

  include Hydra::ModelMethods
  
  has_bidirectional_relationship  "description",   :is_description_of, :has_description,

  has_metadata   :name => "rightsMetadata",                 :type =>Hydra::RightsMetadata
  has_metadata   :name => "descMetadata",                   :type =>ActiveFedora::QualifiedDublinCoreDatastream


end
