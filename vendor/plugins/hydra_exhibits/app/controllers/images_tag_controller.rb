require 'mediashelf/active_fedora_helper'
class ImagesTagController < ApplicationController
  include MediaShelf::ActiveFedoraHelper
  
  before_filter :require_solr, :require_fedora, :only=>[:show, :create, :destroy]
  def new
    render :partial=>"images/new"
  end
  def show
    if params.has_key?("field")
        
        @response, @document = get_solr_response_for_doc_id
        pid = doc[:id] ? doc[:id] : doc[:id.to_s]
        pid ? @component = Component.load_instance_from_solr(pid,@document) : @component = nil
        #@sub_collection.nil? @members = [] : @members = @sub_collection.members
        # @document = SolrDocument.new(@response.docs.first)
        result = @document["#{params["field"]}_t"]
        # document_fedora = SaltDocument.load_instance(params[:id])
        # result = document_fedora.datastreams_in_memory[params["datastream"]].send("#{params[:field]}_values")
        unless result.nil?
          if params.has_key?("field_index")
            result = result[params["field_index"].to_i-1]
          elsif result.kind_of?(Array)
            result = result.first
          end
        end
        respond_to do |format|
          format.html     { render :text=>result }
          format.textile  { render :text=> white_list( RedCloth.new(result, [:sanitize_html]).to_html ) }
        end
      else
        redirect_to :controller=>"catalog", :action=>"show"
      end
  end
  def create
    logger.info("In the ImageTag controller.............")
    af_model = retrieve_af_model(params[:content_type], :default=>Component)
    @document_fedora = af_model.find(params[:asset_id])
    ct = params[:tag_type]
    logger.info("In the ImagesTagController, ct = #{ct}")
    inserted_node, new_node_index = @document_fedora.insert_new_node('image_tag', opts={})
#    inserted_node, new_node_index = @document_fedora.insert_new_node(ct, opts={})
    @document_fedora.save
    partial_name = "images/edit_image"
    render :partial=>partial_name, :locals=>{"edit_image_tag".to_sym =>inserted_node, "edit_image_counter".to_sym =>new_node_index}, :layout=>false
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
end
