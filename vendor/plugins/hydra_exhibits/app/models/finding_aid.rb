require 'hydra'

class FindingAid < ActiveFedora::Base

  include Hydra::ModelMethods
  
  has_bidirectional_relationship  "part_of",   :is_part_of, :has_part
  
  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 

#  has_metadata :name => "descMetadata", :type => EadXml
  
  def datastream_url ds_name="content"
    "#{Fedora::Repository.instance.base_url}/get/#{pid}/#{ds_name}"
  end

  has_metadata :name => "properties", :type => ActiveFedora::MetadataDatastream do |m|
    m.field 'finding_aid_for', :string
  end

  def insert_new_node(type, opts)
    ds = self.datastreams_in_memory["descMetadata"]
    node, index = ds.insert_node(type, opts)
    return node, index
  end
  
  def finding_aid_for
    return @finding_aid_for if (defined? @finding_aid_for)
    values = self.fields[:finding_aid_for][:values]
    @finding_aid_for = values.any? ? values.first : ""
  end

end
