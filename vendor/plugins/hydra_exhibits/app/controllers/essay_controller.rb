require 'mediashelf/active_fedora_helper'

class EssayController < ApplicationController

  include Hydra::AssetsControllerHelper
  include Hydra::FileAssetsHelper
  include Hydra::RepositoryController
  include MediaShelf::ActiveFedoraHelper
  include Blacklight::SolrHelper
  include WhiteListHelper
  include Blacklight::CatalogHelper
  include ApplicationHelper
  include EssayHelper

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
      layout = false
    end
    #@essay=Essay.load_instance(params[:id])
    #@document_fedora = the_model.load_instance(params[:id])
    @asset=Collection.load_instance(params[:collection_id])
    essay_ids=@asset.description_inbound_ids
    logger.error("pid: #{@asset.pid}")
    render :partial=>"essays/index", :layout=>layout
  end

  def new
    render :partial=>"new", :layout=>false
  end

  def create
=begin attributes = params
    unless attributes.has_key?(:label)
      attributes[:label] = "Essay"
    end
    essay_pid=  generate_pid(params[:key], 'Essay')
    if (!asset_available(essay_pid, "Essay" ))
      @essay = Essay.new({:pid=>lot_pid})
      apply_depositor_metadata(@essay)
      @lot.save
      @essay.update_indexed_attributes(attributes)
      logger.debug "Created essay with pid #{@essay.pid}."
    else
      logger.debug "essay is create already. So load the obj"
      @essay=load_instance("Essay",essay_pid)
    end
    add_named_relationship(@essay, params[:collection_content_type], params[:collection_pid])
    @building=Building.load_instance(params[:building_pid])
    render :partial=>"essays/index", :locals=>{"essays".to_sym =>@object.essay_list}, :layout=>false
    #render :text => "Successfull added relationship betweeb #{params[:building_pid]} and #{@lot.pid}."
=end

    @essay = create_and_save_essay_from_params
    apply_depositor_metadata(@essay)
    if !params[:collection_id].nil?
      @collection =  ActiveFedora::Base.load_instance(params[:collection_id])
      #@collection.file_objects_append(@file_asset)
      @essay.description_of_append(@collection)
      @essay.save
      @collection.save
    end
    @document_fedora = Essay.load_instance(@essay.pid)
    logger.debug "Essay Document: #{@document_fedora}"
    logger.debug "Created #{@essay.pid}."
    render :nothing => true
  end

  def destroy
    check_required_params([:content_model,:id,:collection_content_type,:collection_pid])
    @lot=load_instance(params[:content_model],params[:id])
    remove_named_relationship(@essay, params[:collection_content_type], params[:collection_pid])
    render :text => "Deleted #{params[:id]} from realtionships from #{params[:collection_pid]}."
  end

  def show
     redirect_to(:action => 'index', :q => nil , :f => nil)
  end

end
