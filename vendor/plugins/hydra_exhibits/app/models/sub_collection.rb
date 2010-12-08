require "hydra"

class SubCollection < ActiveFedora::Base

  has_bidirectional_relationship "member_of", :is_member_of, :has_member
  has_bidirectional_relationship "members", :has_member, :is_member_of
  has_bidirectional_relationship "highlighted", :has_subset, :is_subset_of
  has_bidirectional_relationship  "descriptions",   :has_description, :is_description_of

  #override the members and highlighted relationship methods

  def filtered_members
    #if facet defined then return this list of things
    []
  end

  def filtered_highlighted
    #if facet defined for highlighted subset then use that list
    #filter would combine members facet (if defined) and highlighted facets,
    #or if not defined apply filter to relationship members list?
    []
  end

  
end
