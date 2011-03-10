require 'mediashelf/active_fedora_helper'
class ImagesTagController < ApplicationController
  include Hydra::AssetsControllerHelper
  include Hydra::FileAssetsHelper  
  include Hydra::RepositoryController  
  include MediaShelf::ActiveFedoraHelper
  include Blacklight::SolrHelper
  include WhiteListHelper
  include Blacklight::CatalogHelper
  include ApplicationHelper
  include ComponentsControllerHelper

  helper :hydra, :metadata, :infusion_view
  before_filter :require_solr, :require_fedora

  def show
    redirect_to url_for(:action=>"edit", :controller=>"catalog", :label => params[:label], :id=>@asset.pid)
  end

  def new
    @asset = Component.load_instance(params[:item_id])
    @asset.insert_new_node('image', {"descMetadata"=>"item_daogrp_daoloc_daoloc_href"})
    @asset.save
    redirect_to url_for(:action=>"edit", :controller=>"catalog", :label => params[:label], :id=>@asset.pid)
  end

  def destroy
    @asset = Component.load_instance(params[:item_id])
    @asset.remove_image('image', params[:image_counter])
    @asset.save
    redirect_to url_for(:action=>"edit", :controller=>"catalog", :label => params[:label], :id=>@asset.pid)
  end
  
  def index
    redirect_to url_for(:action=>"edit", :controller=>"catalog", :label => params[:label], :id=>@asset.pid)
  end

  def update_image_fields(obj, term, value, counter)
    obj.update_indexed_attributes ({term=>{"#{counter.to_s}"=>value}} )
    #obj.save
  end
end
