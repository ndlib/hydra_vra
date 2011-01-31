require 'mediashelf/active_fedora_helper'

class DescriptionsController < ApplicationController

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
    logger.error("Index param: #{params.inspect}")
    if params[:layout] == "false"      
      layout = false
    end
    #@essay=Essay.load_instance(params[:id])
    #@document_fedora = the_model.load_instance(params[:id])
    @asset=Collection.load_instance(params[:collection_id])
    description_ids=@asset.description_inbound_ids
    logger.error("pid: #{@asset.pid}")
    render :partial=>"descriptions/edit_description", :layout=>layout
  end

  def new
    render :partial=>"new", :layout=>false
  end

  def create
    logger.debug "Description params: #{params.inspect}"
    @description = create_and_save_description
    apply_depositor_metadata(@description)
    if !params[:asset_id].nil?
      @asset =  ActiveFedora::Base.load_instance(params[:asset_id])      
      @description.description_of_append(@asset)
      @description.save      
    end

    the_model = ActiveFedora::ContentModel.known_models_for( @asset ).first
    if the_model.nil?
      raise "Unknown content type for the object with pid #{@asset.pid}"
    end
    @document_fedora = the_model.load_instance(@asset.pid)
    logger.debug "description Document: #{@document_fedora}"
    logger.debug "Created #{@description.pid}. Now asset has #{@document_fedora.description_list} description"
    render :partial=>"descriptions/_edit_description", :locals=>{"asset".to_sym =>@document_fedora}, :layout=>false
  end

  def update
    raise "Description id cannot be nil or blank to update description"  if params[:description_id].blank?
    af_model = retrieve_af_model(params[:content_type])
    unless af_model
      af_model = Description
    end
    @description=af_model.load_instance(params[:description_id])       
    updater_method_args = prep_updater_method_args(params)
    if(params[:load_datastream] == "true")
      content = updater_method_args[:params]["descriptiondatastream"]
      ds_id=updater_method_args[:opts][:datastreams]
      logger.error("Param: #{updater_method_args[:params]["descriptiondatastream"].inspect}, opts: #{updater_method_args[:opts][:datastreams].inspect}")
      @description.update_named_datastream("descriptiondatastream",{:dsid=>ds_id,:file=>content, :label=>"test description", :mimeType=>"text/html"})
      @description.save
    else
      logger.debug("attributes submitted: #{updater_method_args.inspect}")
      # this will only work if there is only one datastream being updated.
      # once ActiveFedora::MetadataDatastream supports .update_datastream_attributes, use that method instead (will also be able to pass through params["asset"] as-is without usin prep_updater_method_args!)
      result = @description.update_indexed_attributes(updater_method_args[:params], updater_method_args[:opts])
      @description.save
      response = Hash["updated"=>[]]      
      result.each_pair do |field_name,changed_values|
        changed_values.each_pair do |index,value|
          response["updated"] << {"field_name"=>field_name,"index"=>index,"value"=>value}
          content = value
        end
      end
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
    end
  end

  def destroy
    check_required_params([:asset_content_type,:id,:asset_id])
    logger.debug("Params sent to delete description: #{params.inspect}")
    @description=Description.load_instance(params[:id])
    if  params[:asset_content_type].eql?("exhibit")
      @exhibit=Exhibit.load_instance(params[:asset_id])
      @exhibit.update_indexed_attributes(:main_description=>{"0"=>""})
      @exhibit.save
    end
    @description.delete
    render :text => "Deleted description Successfully."
    #render :partial => "exhibits/edit_settings", :locals => {:content => "exhibit", :document_fedora => @exhibit}
  end

  def show
      af_model = retrieve_af_model(params[:content_type])
      logger.error("cm:#{params[:content_type].inspect}, pid:#{params[:id].inspect}")
      raise "Content model #{params[:content_type]} is not of type ActiveFedora:Base" unless af_model        
      if params.has_key?(:description_id) && params[:load_datastream] == "true"
        resource = af_model.load_instance(params[:description_id])
        logger.error("Model: #{af_model}, resource:#{resource.pid}")
        description_content= resource.content
        logger.error("Actual Content: #{description_content.inspect}")
      else
        if params.has_key?("field")
          @response, @description_document = get_solr_response_for_doc_id(params[:description_id])
          #logger.debug("ID: #{@description_document["id_t"].inspect}")
          @description_document["#{params["field"]}_t"].blank? ? description_content = "" : description_content = @description_document["#{params["field"]}_t"]          
          unless description_content.nil?
            if params.has_key?("field_index")
              description_content = description_content[params["field_index"].to_i-1]
            elsif description_content.kind_of?(Array)
              description_content = description_content.first
            end
          end
        end
      end
      logger.debug("content: #{description_content.inspect}")
      respond_to do |format|
          format.html     { render :text=>description_content }
          format.textile  { render :text=> description_content.blank? ? "Add content here" : white_list( RedCloth.new(description_content, [:sanitize_html]).to_html ) }
      end
  end

  def add
    updater_method_args = prep_updater_method_args(params)
    content = updater_method_args[:params]["descriptiondatastream"]
    logger.error("Param: #{updater_method_args[:params]["descriptiondatastream"].inspect}, opts: #{updater_method_args[:opts][:datastreams].inspect}")
    @description = create_and_save_description(content)
    apply_depositor_metadata(@description)
    @description.save
    if !params[:id].nil?
      @obj =  ActiveFedora::Base.load_instance(params[:id])
      the_model = ActiveFedora::ContentModel.known_models_for( @obj ).first
      if the_model.nil?
        raise "Unknown content type for the object with pid #{@obj.pid}"
      end
      @asset = the_model.load_instance(params[:id])
      logger.debug "#{@asset.class}"
      @description.description_of_append(@asset)
      @description.save
      @asset.save
      @asset = the_model.load_instance(params[:id])
      @description=Description.load_instance(@description.pid)
      logger.debug "Created #{@description.pid}. Now asset has #{@asset.descriptions_inbound_ids.count} descriptions and pids are #{@asset.descriptions_inbound_ids}"
    end

    if params.has_key?(:description_title) && !params[:description_title].blank?
      logger.debug "description title: #{params[:description_title]}, description pid: #{@description.pid}"
      @description.update_indexed_attributes(:title=>{"0"=>params[:description_title]})
      @description.save
      response = Hash["updated"=>[]]
      response["updated"] << {"title update"=>params[:description_title]}
    end

    respond_to do |want|
      want.html {
        render :partial=>"descriptions/edit_description", :locals => {:asset => @asset}
      }
    end
  end

  def update_title
     if params.has_key?(:description_id)
      af_model = retrieve_af_model(params[:content_type])
      unless af_model
        af_model = Description
      end
      @description=af_model.load_instance(params[:description_id])
    end
    if params.has_key?(:description_title) && !params[:description_title].blank?
      logger.debug "description title: #{params[:description_title]}, description pid: #{@description.pid}"
      @description.update_indexed_attributes(:title=>{"0"=>params[:description_title]})
      @description.save
      response = Hash["updated"=>[]]
      response["updated"] << {"title update"=>params[:description_title]}
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
    end
  end

end
