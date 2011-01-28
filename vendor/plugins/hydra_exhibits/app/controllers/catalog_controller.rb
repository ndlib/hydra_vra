class CatalogController

  #include application helper in order to get override of build_lucene_query method
  include ApplicationHelper

  alias :blacklight_facet_limit_for :facet_limit_for

  # If exhibit is defined and in an exhibit browse view 
  # then do not set limit on facet values displayed.
  # Otherwise use code lifted from catalog controller in blacklight plugin
  def facet_limit_for(facet_field)
    (params[:exhibit_id] && !params[:render_search].blank?) ? nil : blacklight_facet_limit_for(facet_field) 
  end
  helper_method :facet_limit_for 
end
