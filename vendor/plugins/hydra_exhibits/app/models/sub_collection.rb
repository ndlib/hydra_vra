require "hydra"

class SubCollection < ActiveFedora::Base

  include Collection

  has_relationship "member_of", :is_member_of, :has_member

  #override the members and highlighted relationship methods

  def facet_members
    #if facet defined then return this list of things
    []
  end

  def facet_highlighted
    #if facet defined for highlighted subset then use that list
    #filter would combine members facet (if defined) and highlighted facets,
    #or if not defined apply filter to relationship members list?
    []
  end

  
end
