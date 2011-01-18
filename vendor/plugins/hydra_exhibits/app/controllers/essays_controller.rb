require 'mediashelf/active_fedora_helper'

class EssaysController < ApplicationController

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
    logger.debug "Essay params: #{params.inspect}"
    @essay = create_and_save_essay
    apply_depositor_metadata(@essay)
    if !params[:asset_id].nil?
      @asset =  ActiveFedora::Base.load_instance(params[:asset_id])      
      @essay.description_of_append(@asset)
      @essay.save
      @asset.save
    end

    the_model = ActiveFedora::ContentModel.known_models_for( @asset ).first
    if the_model.nil?
      raise "Unknown content type for the object with pid #{@asset.pid}"
    end
    @document_fedora = the_model.load_instance(@asset.pid)
    logger.debug "Essay Document: #{@document_fedora}"
    logger.debug "Created #{@essay.pid}. Now asset has #{@document_fedora.description_list} essays"
    render :partial=>"essays/index", :locals=>{"asset".to_sym =>@document_fedora}, :layout=>false
  end

  def update
    if params.has_key?(:essay_id)
      af_model = retrieve_af_model(params[:content_type])
      unless af_model
        af_model = Essay
      end
      @essay=af_model.load_instance(params[:essay_id])
      @essay.save
    end
    if !params[:essay_action].eql?("update_essay_title")
      updater_method_args = prep_updater_method_args(params)
      content = updater_method_args[:params]["essay_content"]
      ds_id=updater_method_args[:opts][:datastreams]
      logger.error("Param: #{updater_method_args[:params]["essay_content"].inspect}, opts: #{updater_method_args[:opts][:datastreams].inspect}")
    end
    if params.has_key?(:essay_action) && params[:essay_action].eql?("update_essay")
      @essay.update_named_datastream("essaydatastream",{:dsid=>ds_id,:file=>content, :label=>"test essay", :mimeType=>"text/html"})
      @essay.save
    elsif params.has_key?(:essay_action) && params[:essay_action].eql?("insert_essay")
      @essay = create_and_save_essay(content)
      apply_depositor_metadata(@essay)
      @essay.save
      if !params[:id].nil?
        @obj =  ActiveFedora::Base.load_instance(params[:id])
        the_model = ActiveFedora::ContentModel.known_models_for( @obj ).first
        if the_model.nil?
          raise "Unknown content type for the object with pid #{@obj.pid}"
        end
        @asset = the_model.load_instance(params[:id])
        logger.debug "#{@asset.class}"
        @essay.description_of_append(@asset)
        @essay.save
        @asset.save
        @asset = the_model.load_instance(params[:id])
        @essay=Essay.load_instance(@essay.pid)
      end
      logger.debug "Created #{@essay.pid}. Now asset has #{@asset.descriptions_inbound_ids.count} essays and pids are #{@asset.descriptions_inbound_ids}"
    #else
     # raise "Unknown action to perform"
    end
    if params.has_key?(:essay_title) && !params[:essay_title].blank?
      logger.debug "essay title: #{params[:essay_title]}, Essay pid: #{@essay.pid}"
      @essay.update_indexed_attributes(:title=>{"0"=>params[:essay_title]})
      @essay.save
      response = Hash["updated"=>[]]
      response["updated"] << {"title update"=>params[:essay_title]}
      logger.debug("if loop response-> #{response.inspect}")
    end

    respond_to do |want|
      want.js {
        logger.debug("render js response-> #{response.inspect}")
        render :json=> response
      }
      want.textile {
        if content.kind_of?(Hash)
          content = content.values.first
        end
        render :text=> white_list( RedCloth.new(content, [:sanitize_html]).to_html )
      }
      want.html {
        render :partial=>"essays/index", :locals => {:asset => @asset}
      }
    end
  end

  def destroy
    check_required_params([:asset_content_type,:id,:asset_id])
    #unless af_model
      af_model = Essay
    #end
    @essay=af_model.load_instance(params[:id])
    #remove_named_relationship(@essay, params[:asset_content_type], params[:asset_pid])
    @essay.delete
    #flash[:notice]= "Deleted essay " + params[:id]
    render :text => "Deleted Essay Successfully."
  end

  def show
      if params.has_key?(:essay_id)
        #essay_content=essay_content(params[:content_model],params[:id],params[:datastream_name])
        af_model = retrieve_af_model(params[:content_type])
        logger.error("cm:#{params[:content_type].inspect}, pid:#{params[:id].inspect}")
        raise "Content model #{params[:content_type]} is not of type ActiveFedora:Base" unless af_model
        resource = af_model.load_instance(params[:essay_id])
        logger.error("Model: #{af_model}, resource:#{resource.pid}")
        essay_content= resource.essaydatastream(params[:datastream_name]).first.content
        logger.error("Actual Content: #{essay_content.inspect}")
      else        
       essay_content= params[:temp_content]
      end
      respond_to do |format|
          format.html     { render :text=>essay_content }
          format.textile  { render :text=> white_list( RedCloth.new(essay_content, [:sanitize_html]).to_html ) }
      end
  end

end
