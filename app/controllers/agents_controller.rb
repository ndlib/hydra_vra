require 'mediashelf/active_fedora_helper'
class AgentsController < ApplicationController
  include MediaShelf::ActiveFedoraHelper
  before_filter :require_solr, :require_fedora
  def new
    render :partial=>"agents/new"
  end
  def create
    af_model = retrieve_af_model(params[:content_type], :default=>VraSample)
    @document_fedora = af_model.find(params[:asset_id])
    
    ct = params[:tag_type]
    inserted_node, new_node_index = @document_fedora.insert_new_node(ct, opts={})
    @document_fedora.save
    partial_name = "agents/edit_#{ct}"
    render :partial=>partial_name, :locals=>{"edit_#{ct}".to_sym =>inserted_node, "edit_#{ct}_counter".to_sym =>new_node_index}, :layout=>false
  end
  def destroy
    af_model = retrieve_af_model(params[:content_type], :default=>VraSample)
    @document_fedora = af_model.find(params[:asset_id])
    @document_fedora.remove_agent(params[:contributor_type], params[:index])
    result = @document_fedora.save
    render :text=>result.inspect
  end
end