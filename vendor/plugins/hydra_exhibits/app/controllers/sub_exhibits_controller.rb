require 'mediashelf/active_fedora_helper'

class SubExhibitsController < ApplicationController

  include Hydra::AssetsControllerHelper
  include Hydra::FileAssetsHelper
  include Hydra::RepositoryController
  include MediaShelf::ActiveFedoraHelper
  include Blacklight::SolrHelper
  include WhiteListHelper
  include Blacklight::CatalogHelper
  include ApplicationHelper
  include DescriptionsHelper

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
  raise not_found if not_found.any?
  end

  def index
    render :partial=>"index", :layout=>false    
  end

  def new
    af_model = retrieve_af_model(params[:content_type])
    logger.debug("Af Model from subexhibit: #{af_model.inspect}")
    if af_model
      @subexhibit = af_model.new(:namespace=>"RBSC-CURRENCY")
      apply_depositor_metadata(@subexhibit)
      set_collection_type(@subexhibit, params[:content_type])
      rights_ds=@subexhibit.datastreams_in_memory["rightsMetadata"]
      rights_ds.update_permissions({"group"=>{"public"=>"read"}})
      @subexhibit.save
    end

    if !params[:selected_facets].nil?
      logger.debug("Selected facets: #{params[:selected_facets].inspect}")
      @subexhibit.selected_facets_append(params[:selected_facets])
      @subexhibit.save
    end

    if !params[:exhibit_id].nil?
      @exhibit =  ActiveFedora::Base.load_instance(params[:exhibit_id])
      @subexhibit.subset_of_append(@exhibit)
      @subexhibit.save
      @exhibit.save
    end
    logger.debug("Selected faceted added to subexhibit: #{@subexhibit.selected_facets}")
    
    redirect_to url_for(:action=>"edit", :controller=>"catalog", :id=>@subexhibit.id, :f=>@subexhibit.selected_facets_for_params,:class=>"facet_selected", :exhibit_id=>params[:exhibit_id], :render_search=>"false")
  end

  def update
    logger.debug("Params send to update: #{params.inspect}")
    response = Hash["updated"=>[]]

    af_model = retrieve_af_model(params[:content_type])
    unless af_model
      af_model = SubExhibit
    end
    @asset = af_model.load_instance(params[:id])
    if params[:featured_action].eql?("add")
      if !params[:featured_items].blank?
        items=params[:featured_items].split(',')
        logger.debug("Items to Highlight in #{af_model} => #{items.inspect}")
        sub_exhibit_featured = Array.new
        items.each do |item|
          obj=ActiveFedora::Base.load_instance(item)
         @asset.featured_append(obj)
          obj.save
          @asset.save
          sub_exhibit_featured<<item
        end
        response["updated"] << {"#{af_model}_featured"=>sub_exhibit_featured}
      end
      render :partial => 'shared/show_featured', :locals => {:content=>params[:content_type], :asset=>@asset}
    else
      raise "error, Item id not available in parameters list for removing from featured list" if params[:item_id].blank?
      params[:item_id]? item = params[:item_id] : item =""
      logger.debug("Items to remove as Featured from sub_exhibit => #{item.inspect}")
      obj=ActiveFedora::Base.load_instance(item)
      @asset.featured_remove(obj)
      obj.save
      @asset.save
      render :text => "Successfully removed #{obj.pid} from featured list"
    end
  end  

end
