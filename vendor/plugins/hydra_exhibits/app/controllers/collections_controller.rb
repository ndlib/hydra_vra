require 'net/http'
require 'mediashelf/active_fedora_helper'
require "#{RAILS_ROOT}/vendor/plugins/hydra_exhibits/app/models/ead_xml.rb"

class CollectionsController < CatalogController
  include Hydra::AssetsControllerHelper
  include Hydra::FileAssetsHelper  
  include Hydra::RepositoryController  
  include MediaShelf::ActiveFedoraHelper
  include Blacklight::SolrHelper
  include WhiteListHelper
  include Blacklight::CatalogHelper
  include ApplicationHelper
  include CollectionsControllerHelper

  helper :hydra, :metadata, :infusion_view

  #before_filter :initialize_collection, :except=>[:index, :new]
  before_filter :require_solr, :require_fedora, :only=>[:show, :edit, :index, :new, :update]
  def index
    @collections = Collection.find_by_solr(:all).hits.map{|result| Collection.load_instance_from_solr(result["id"])}
  end

  def update
    af_model = retrieve_af_model(params[:content_type])
    unless af_model 
      af_model = Collection
    end
    @document = af_model.find(params[:id])
    updater_method_args = prep_updater_method_args(params)
    result = @document.update_indexed_attributes(updater_method_args[:params], updater_method_args[:opts])
    @document.save
    response = Hash["updated"=>[]]
    last_result_value = ""
    result.each_pair do |field_name,changed_values|
      changed_values.each_pair do |index,value|
        response["updated"] << {"field_name"=>field_name,"index"=>index,"value"=>value} 
        last_result_value = value
      end
    end
    logger.debug("returning #{response.inspect}")

  # If handling submission from jeditable (which will only submit one value at a time), return the value it submitted
    if params.has_key?(:field_id)
      response = last_result_value
    end

    respond_to do |want| 
      want.js {
        render :json=> response
      }
      want.textile {
        if response.kind_of?(Hash)
          response = response.values.first
        end
        render :text=> white_list( RedCloth.new(response, [:sanitize_html]).to_html )
      }
    end
  end

  def new
    content_type = params[:content_type]
    af_model = retrieve_af_model(content_type)
    if af_model
      @asset = create_and_save_collection(af_model)
    end
    redirect_to url_for(:action=>"edit", :controller=>"catalog", :label => params[:label], :id=>@asset.pid, :exhibit_id => params[:exhibit_id], :render_search => params[:render_search], :viewing_context => params[:viewing_context])
  end


  def show  
    show_without_customizations[:exhibit_id => params[:exhibit_id], :render_search => params[:render_search], :viewing_context => params[:viewing_context]]
  end

end
