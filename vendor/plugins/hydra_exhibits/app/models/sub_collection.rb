require "hydra"

class SubCollection < ActiveFedora::Base

  include Hydra::GenericContent

  has_bidirectional_relationship "subset_of", :is_subset_of, :has_subset  
  has_bidirectional_relationship "members", :has_member, :is_member_of
  has_bidirectional_relationship "highlighted", :has_part, :is_part_of
  has_bidirectional_relationship  "descriptions",   :has_description, :is_description_of

  #override the members and highlighted relationship methods
  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 

  # Assumes each field name is the facet and values selected are in values
  has_metadata :name => "selected_facets", :type => PropertiesDatastream

  alias_method :id, :pid
  
  #returns hash of facet and value pairs
  def selected_facets
    datastreams["selected_facets"].values
  end

  def selected_facets_append(hash={})
    datastreams["selected_facets"].update_values(hash)
  end

  #def facets
  #  {"dsc_0_collection_0_did_0_unittitle_0_imprint_0_publisher_facet"=>"Connecticut"}
  #end

  def highlighted_facets
    #if facet defined for highlighted subset then use that list
    #filter would combine members facet (if defined) and highlighted facets,
    #or if not defined apply filter to relationship members list?
    {}
  end

  def description_list
    descriptions.any? ? descriptions : nil
  end

  
end
