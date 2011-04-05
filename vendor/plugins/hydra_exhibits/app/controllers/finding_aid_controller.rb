require 'mediashelf/active_fedora_helper'
class FindingAidController < CatalogController

  before_filter :initialize_exhibit, :except=>[:index, :new]
  before_filter :require_solr, :require_fedora, :only=>[:new,:index]
  before_filter :set_page_style, :only => :show

  include Hydra::AssetsControllerHelper
  include ApplicationHelper
  def show
#    show_without_customizations[:finding_id => params[:finding_id], :exhibit_id => params[:exhibit_id], :render_search => params[:render_search], :viewing_context => params[:viewing_context]]
    render :action => params[:finding_aid], :finding_id => params[:finding_id], :exhibit_id => params[:exhibit_id], :render_search => params[:render_search], :viewing_context => params[:viewing_context], :layout => "application"
  end    
end
