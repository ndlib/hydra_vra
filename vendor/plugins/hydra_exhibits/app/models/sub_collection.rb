require "hydra"

class SubCollection < ActiveFedora::Base

  include Hydra::GenericContent

#  has_bidirectional_relationship "member_of", :is_member_of, :has_member
#  has_bidirectional_relationship "members", :has_member, :is_member_of
#  has_bidirectional_relationship "highlighted", :has_subset, :is_subset_of
  has_bidirectional_relationship  "descriptions",   :has_description, :is_description_of

  #override the members and highlighted relationship methods
  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 

  # A place to put extra metadata values
  #has_metadata :name => "members_facets", :type => ActiveFedora::MetadataDatastream do |m|
  #end
  
  def facets
    {"dsc_0_collection_0_did_0_unittitle_0_imprint_0_publisher_facet"=>"Connecticut"}
  end

  def highlighted_facets
    #if facet defined for highlighted subset then use that list
    #filter would combine members facet (if defined) and highlighted facets,
    #or if not defined apply filter to relationship members list?
    {}
  end

  
end
