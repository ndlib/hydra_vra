require 'mediashelf/active_fedora_helper'
class FindingAidController < CatalogController
  include Hydra::AssetsControllerHelper
  include Hydra::FileAssetsHelper  
  include Hydra::RepositoryController  

  before_filter :initialize_exhibit, :except=>[:index, :new]
  before_filter :require_solr, :require_fedora, :only=>[:new,:index]
  before_filter :set_page_style, :only => :show

  include Hydra::AssetsControllerHelper
  include ApplicationHelper
  def show
#    show_without_customizations[:finding_id => params[:finding_id], :exhibit_id => params[:exhibit_id], :render_search => params[:render_search], :viewing_context => params[:viewing_context]]

    puts "FindingAid: #{params[:finding_id]}"
    if(params.keys.include? "download")
      @file_asset = FindingAid.load_instance(params[:finding_id])
      send_datastream @file_asset.datastreams_in_memory["EAD"]
    else
      render :action => params[:finding_aid], :finding_id => params[:finding_id], :exhibit_id => params[:exhibit_id], :render_search => params[:render_search], :viewing_context => params[:viewing_context], :layout => "application"
    end
  end

  def download
    file = params[:file]
    send_datastream file.datastreams_in_memory["EAD"]
  end

end
