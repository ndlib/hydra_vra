require "hydra"
#Currency
class Component < ActiveFedora::Base
  
  include Hydra::ModelMethods

  has_bidirectional_relationship "member_of", :is_member_of, :has_member
  has_bidirectional_relationship "members", :has_member, :is_member_of
  has_bidirectional_relationship "highlighted", :has_subset, :is_subset_of
  has_bidirectional_relationship  "descriptions",   :has_description, :is_description_of
  #just use parts relationship instead?
  #has_bidirectional_relationship "page", :has_part_of, :is_part_of
 
  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 
  
  # Uses the Hydra MODS Article profile for tracking most of the descriptive metadata
  has_metadata :name => "descMetadata", :type => EadXml
  
  # A place to put extra metadata values
  has_metadata :name => "properties", :type => ActiveFedora::MetadataDatastream do |m|
  end
  
#  def initialize(attrs={})
#    unless attrs[:pid]
#      attrs = attrs.merge!({:pid=>Fedora::Repository.instance.nextid})  
#      @new_object=true
#    else
#      @new_object = attrs[:new_object] == false ? false : true
#    end
#    @inner_object = Fedora::FedoraObject.new(attrs)
#    @datastreams = {}
#    configure_defined_datastreams
#
#    @component_type = attrs[:component_type]
#  end
  
  def insert_new_node(type, opts)
    ds = self.datastreams_in_memory["descMetadata"]
    node, index = ds.insert_node(type, opts)
    return node, index
  end
  
  def get_component_level
    return @component_level
  end
  
end
