require 'mediashelf/active_fedora_helper'

class SubCollectionsController < ApplicationController

  include Hydra::AssetsControllerHelper
  include Hydra::FileAssetsHelper
  include Hydra::RepositoryController
  include MediaShelf::ActiveFedoraHelper
  include Blacklight::SolrHelper
  include WhiteListHelper
  include Blacklight::CatalogHelper
  include ApplicationHelper
  include EssaysHelper

  helper :hydra, :metadata, :infusion_view
  before_filter :require_fedora, :require_solr
  #before_filter :require_solr, :only=>[:index, :create, :show, :destroy]

  def check_required_params(required_params)
  not_found = ""
  if required_params.respond_to?(:each)
    required_params.each do |param|
      not_found = not_found.concat("#{param} parameter is required\n") unless params.has_key?(param)
    end
  end
  raise not_found if not_found.length > 0
  end

  def index
    render :partial=>"index", :layout=>false
    render :text => "Deleted Essay Successfully."
  end

  def new
    af_model = retrieve_af_model(params[:content_type])
    if af_model
      @subcollection = af_model.new(:namespace=>"RBSC-CURRENCY")
      apply_depositor_metadata(@subcollection)
      set_collection_type(@subcollection, params[:content_type])
      @subcollection.save
    end

    if !params[:selected_facets].nil?
      logger.debug("Selected facets: #{params[:selected_facets].inspect}")
      @subcollection.selected_facets_append(params[:selected_facets])
      @subcollection.save
    end

    if !params[:exhibit_id].nil?
      @exhibit =  ActiveFedora::Base.load_instance(params[:exhibit_id])
      @subcollection.subset_of_append(@exhibit)
      @subcollection.save
      @exhibit.save
    end
    logger.debug("Selected faceted added to subcollection: #{@subcollection.selected_facets}")
    redirect_to url_for(:action=>"edit", :controller=>"catalog", :id=>@subcollection.id, :f=>params[:selected_facets],:class=>"facet_selected", :exhibit_id=>params[:exhibit_id])
  end

  def update
    logger.debug("Params send to update: #{params.inspect}")
    response = Hash["updated"=>[]]

    af_model = retrieve_af_model(params[:content_type])
    if af_model
      @subcollection = af_model.load_instance(params[:id])
    end

    if !params[:sub_collection_items].blank?
      items=params[:sub_collection_items].split(',')
      logger.debug("Items to Highlight sub_collection => #{items.inspect}")
      sub_collection_highlighted = Array.new
      items.each do |item|
        obj=ActiveFedora::Base.load_instance(item)
        @subcollection.highlighted_append(obj)
        obj.save
        @subcollection.save
        sub_collection_highlighted<<item
      end
      response["updated"] << {"sub_collection_highlighted"=>sub_collection_highlighted}
    end


    #render :text => "reached update."
    respond_to do |want|
        want.js {
          render :json=> response
        }
    end
  end

  def show
      
  end

end
