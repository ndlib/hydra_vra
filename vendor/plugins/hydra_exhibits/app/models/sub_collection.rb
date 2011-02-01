require "hydra"

class SubCollection < ActiveFedora::Base

  include Hydra::GenericContent

  has_bidirectional_relationship "subset_of", :is_subset_of, :has_subset  
  has_bidirectional_relationship "members", :has_member, :is_member_of
  has_relationship "featured", :has_part
  has_bidirectional_relationship  "descriptions",   :has_description, :is_description_of

  #override the members and featured relationship methods
  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 

  # Assumes each field name is the facet and values selected are in values
  has_metadata :name => "selected_facets", :type => PropertiesDatastream

  alias_method :id, :pid
  
  #returns hash of facet and value pairs
  def selected_facets
    datastreams["selected_facets"].values
  end

  #returns hash of facet to array of values for adding to params
  def selected_facets_for_params
    h = {}
    datastreams["selected_facets"].values.each_pair do |key, value|
      h[key] = []
      h[key] << value
    end
    h
  end

  def selected_facets_append(hash={})
    datastreams["selected_facets"].update_values(hash)
  end

  #def facets
  #  {"dsc_0_collection_0_did_0_unittitle_0_imprint_0_publisher_facet"=>"Connecticut"}
  #end

  def description_list
    descriptions.any? ? descriptions : nil
  end

  
end
