class CatalogController

  #include application helper in order to get override of build_lucene_query method
  include ApplicationHelper

  before_filter :set_page_style, :only => [:show, :index]
  before_filter :initialize_exhibit

  alias :blacklight_facet_limit_for :facet_limit_for

  def index
    @extra_controller_params ||= {}

    if params[:CKEditor]
      (@response, @document_list) = get_search_results( @extra_controller_params.merge!(:q=>build_lucene_query_with_desc(params[:q])) )
      javascript_includes << ["jquery.includeItem"]
      logger.debug("JS Included: #{javascript_includes.inspect}")
      render :layout => "ckeditor"
    else
      (@response, @document_list) = get_search_results( @extra_controller_params.merge!(:q=>build_lucene_query(params[:q])) )
    end
    @filters = params[:f] || []
    respond_to do |format|
      format.html { save_current_search_params }
      format.rss  { render :layout => false }
    end
    rescue Exception => e
      logger.error("Unparseable search params: #{params.inspect} error: #{e.to_s}")
      flash[:notice] = "Sorry, you've encountered an error. Try a different search."
      redirect_to :action => 'index', :q => nil , :f => nil
  end

  # If exhibit is defined and in an exhibit browse view 
  # then do not set limit on facet values displayed.
  # Otherwise use code lifted from catalog controller in blacklight plugin
  def facet_limit_for(facet_field)
    (params[:exhibit_id] && !params[:render_search].blank?) ? nil : blacklight_facet_limit_for(facet_field) 
  end
  helper_method :facet_limit_for 
end
