require 'mediashelf/active_fedora_helper'
class ReviewsController < CatalogController
    include Hydra::AssetsControllerHelper
    include Hydra::FileAssetsHelper  
    include Hydra::RepositoryController  
    include MediaShelf::ActiveFedoraHelper
    include Blacklight::SolrHelper
    include WhiteListHelper
    include Blacklight::CatalogHelper
    include ApplicationHelper
    include ComponentsControllerHelper

  before_filter :set_page_style, :only => [:show, :index]
  before_filter :initialize_exhibit

  def index
    @extra_controller_params ||= {}

    (@response, @document_list) = get_search_results( @extra_controller_params.merge!(:q=>build_lucene_query_for_review(params[:q])) )
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

end
