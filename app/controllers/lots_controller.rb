require 'mediashelf/active_fedora_helper'

class LotsController < ApplicationController
  
  include Hydra::AssetsControllerHelper
  include Hydra::FileAssetsHelper  
  include Hydra::RepositoryController  
  include MediaShelf::ActiveFedoraHelper
  include Blacklight::SolrHelper
  include WhiteListHelper
  include Blacklight::CatalogHelper
  include ApplicationHelper

  helper :hydra, :metadata, :infusion_view
  before_filter :require_fedora
  before_filter :require_solr, :only=>[:index, :create, :show, :destroy]

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
    logger.error("Index param: #{params.inspect}")
    if params[:layout] == "false"
      # action = "index_embedded"
      layout = false
    end
    @building=Building.load_instance(params[:building_id])
    logger.error("Building pid: #{@building.pid}, lot_list is blank: #{@building.lot_list.blank?}")
    render :partial=>"lots/index", :layout=>layout
  end
  
  def new
    render :partial=>"new", :layout=>false
  end
  
  def create
    attributes = params
    unless attributes.has_key?(:label)
      attributes[:label] = "Lot"
    end
    lot_pid=  generate_pid(params[:key], 'Lot')
    if (!asset_available(lot_pid, "Lot" ))
      @lot = Lot.new({:pid=>lot_pid})
      apply_depositor_metadata(@lot)
      @lot.save
      @lot.update_indexed_attributes(attributes)
      logger.debug "Created Lot with pid #{@lot.pid}."
    else
      logger.debug "Lot is create already. So load the obj"
      @lot=load_instance("Lot",lot_pid)
    end
    add_named_relationship(@lot, params[:building_content_type], params[:building_pid])
    @building=Building.load_instance(params[:building_pid])
    render :partial=>"lots/index", :locals=>{"lots".to_sym =>@object.lot_list}, :layout=>false
    #render :text => "Successfull added relationship betweeb #{params[:building_pid]} and #{@lot.pid}."
  end

  def destroy
    check_required_params([:content_model,:id,:building_content_type,:building_pid])
    @lot=load_instance(params[:content_model],params[:id])
    remove_named_relationship(@lot, params[:building_content_type], params[:building_pid])
    render :text => "Deleted #{params[:id]} from realtionships from #{params[:building_pid]}."
  end

  def show
     redirect_to(:action => 'index', :q => nil , :f => nil)
  end

end
