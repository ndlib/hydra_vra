require 'mediashelf/active_fedora_helper'
class AgentsController < ApplicationController
  include MediaShelf::ActiveFedoraHelper
  before_filter :require_solr, :require_fedora
  def new
    render :partial=>"agents/new"
  end
  def create
    af_model = retrieve_af_model(params[:content_type], :default=>Building)
    @document_fedora = af_model.find(params[:asset_id])
    
    ct = params[:tag_type]
    inserted_node, new_node_index = @document_fedora.insert_new_node(ct, opts={})
    @document_fedora.save
    partial_name = "agents/edit_#{ct}"
    render :partial=>partial_name, :locals=>{"edit_#{ct}".to_sym =>inserted_node, "edit_#{ct}_counter".to_sym =>new_node_index}, :layout=>false
  end
  def destroy
    af_model = retrieve_af_model(params[:content_type], :default=>Building)
    @document_fedora = af_model.find(params[:id])
    logger.error("AfModel: #{af_model}")
    @document_fedora.remove_agent("agent", params[:agent])
    result = @document_fedora.save
    logger.error("Result: #{result.inspect}")
    render :text=> "Agent Node delete successfully"
  end
end