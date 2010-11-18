require 'mediashelf/active_fedora_helper'
class ImagesTagController < ApplicationController
  include MediaShelf::ActiveFedoraHelper
  before_filter :require_solr, :require_fedora
  def new
    render :partial=>"images/new"
  end
  def create
    af_model = retrieve_af_model(params[:content_type], :default=>Building)
    @document_fedora = af_model.find(params[:asset_id])
    ct = params[:tag_type]
    inserted_node, new_node_index = @document_fedora.insert_new_node(ct, opts={})
    @document_fedora.save
    partial_name = "images/edit_#{ct}"
    render :partial=>partial_name, :locals=>{"edit_#{ct}".to_sym =>inserted_node, "edit_#{ct}_counter".to_sym =>new_node_index}, :layout=>false
  end
  def destroy
    af_model = retrieve_af_model(params[:content_type], :default=>Building)
    @document_fedora = af_model.find(params[:id])
    @document_fedora.remove_image("image", params[:image])
    result = @document_fedora.save
    logger.error("Result: #{result.inspect}")
    render :text=> "Image Node delete successfully"
  end
end