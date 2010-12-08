require 'mediashelf/active_fedora_helper'
class ImagesTagController < ApplicationController
  include MediaShelf::ActiveFedoraHelper
  before_filter :require_solr, :require_fedora
  def new
    render :partial=>"images/new"
  end
  def create
    af_model = retrieve_af_model(params[:content_type], :default=>Component)
    @document_fedora = af_model.find(params[:asset_id])
    ct = params[:tag_type]
    logger.info("In the ImagesTagController, ct = #{ct}")
    inserted_node, new_node_index = @document_fedora.insert_new_node('image', opts={})
#    inserted_node, new_node_index = @document_fedora.insert_new_node(ct, opts={})
    @document_fedora.save
    partial_name = "images/edit_image"
    render :partial=>partial_name, :locals=>{"edit_image".to_sym =>inserted_node, "edit_image_counter".to_sym =>new_node_index}, :layout=>false
  end
  def destroy
    af_model = retrieve_af_model(params[:content_type], :default=>Component)
    @document_fedora = af_model.find(params[:id])
    @document_fedora.remove_image("image", params[:image])
    result = @document_fedora.save
    logger.error("Result: #{result.inspect}")
    render :text=> "Image Node delete successfully"
  end
  def update_image_fields(obj, term, value, counter)
    obj.update_indexed_attributes ({term=>{"#{counter.to_s}"=>value}} )
    #obj.save
  end
  def update
      af_model = retrieve_af_model(params[:content_type])
      unless af_model 
        af_model = HydrangeaArticle
      end
      @document = af_model.find(params[:id])
      updater_method_args = prep_updater_method_args(params)
      result = @document.update_indexed_attributes(updater_method_args[:params], updater_method_args[:opts])
      @document.save
      response = Hash["updated"=>[]]
      last_result_value = ""
      result.each_pair do |field_name,changed_values|
        changed_values.each_pair do |index,value|
          response["updated"] << {"field_name"=>field_name,"index"=>index,"value"=>value} 
          last_result_value = value
        end
      end
      if params.has_key?(:field_id)
        response = last_result_value
      end
      respond_to do |want| 
        want.js {
          render :json=> response
        }
        want.textile {
          if response.kind_of?(Hash)
            response = response.values.first
          end
          render :text=> white_list( RedCloth.new(response, [:sanitize_html]).to_html )
        }
      end
    end
end