require 'mediashelf/active_fedora_helper'
class ComponentsController < ApplicationController
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
    
    before_filter :search_session, :history_session
    before_filter :require_fedora, :require_solr
    
    def show
      if params.has_key?("field")
        
        @response, @document = get_solr_response_for_doc_id
        pid = @document[:id] ? @document[:id] : @document[:id.to_s]
        logger.debug("PID: #{pid}")
        pid ? @component = Component.load_instance_from_solr(pid,@document) : @component = nil
#	childern = @component.inbound_relationships[:is_part_of]
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
        redirect_to :controller=>"catalog", :action=>"show", :label=>params[:label]
      end
    end
    
    # Uses the update_indexed_attributes method provided by ActiveFedora::Base
    # This should behave pretty much like the ActiveRecord update_indexed_attributes method
    # For more information, see the ActiveFedora docs.
    # 
    # Examples
    # put :update, :id=>"_PID_", "document"=>{"subject"=>{"-1"=>"My Topic"}}
    # Appends a new "subject" value of "My Topic" to any appropriate datasreams in the _PID_ document.
    # put :update, :id=>"_PID_", "document"=>{"medium"=>{"1"=>"Paper Document", "2"=>"Image"}}
    # Sets the 1st and 2nd "medium" values on any appropriate datasreams in the _PID_ document, overwriting any existing values.
    def update
      af_model = retrieve_af_model(params[:content_type])
      unless af_model 
        af_model = Component
      end
      @document = af_model.find(params[:id])
      if(params.has_keys?"description_id")
	logger.debug "In the select method with value #{params[:description_id]}"
        @asset = af_model.load_instance(params[:id])
        @asset.update_indexed_attributes({:main_page=>{0=>params[:description_id]}})
        @asset.save
	redirect_to url_for(:action=>"edit", :controller=>"catalog", :id=>@asset.pid)
      elsif((params[:field_selectors].has_keys?"properties") && (params[:field_selectors][:properties].has_keys?"subcollection_id"))
        @asset = af_model.load_instance(params[:id])
        @asset.update_indexed_attributes({:subcollection_id=>{"0"=>params[:asset][:properties][:subcollection_id].first.second}})
        @asset.save
	redirect_to url_for(:action=>"edit", :controller=>"catalog", :id=>@asset.pid)
      else
	if(params[:field_selectors][:descMetadata].keys.include?"item_did_unitid")
          @document.update_indexed_attributes({:item_id=>{"0"=>params[:asset][:descMetadata][:item_did_unitid].first.second}})
	  @document.save
        end
        updater_method_args = prep_updater_method_args(params)
   
        logger.debug("attributes submitted: #{updater_method_args.inspect}")
        # this will only work if there is only one datastream being updated.
        # once ActiveFedora::MetadataDatastream supports .update_datastream_attributes, use that method instead (will also be able to pass through params["asset"] as-is without usin prep_updater_method_args!)
        result = @document.update_indexed_attributes(updater_method_args[:params], updater_method_args[:opts])
        @document.save
        #response = attrs.keys.map{|x| escape_keys({x=>attrs[x].values})}
        response = Hash["updated"=>[]]
        last_result_value = ""
        result.each_pair do |field_name,changed_values|
          changed_values.each_pair do |index,value|
            response["updated"] << {"field_name"=>field_name,"index"=>index,"value"=>value} 
            last_result_value = value
          end
        end
        logger.debug("returning #{response.inspect}")

    
      # If handling submission from jeditable (which will only submit one value at a time), return the value it submitted
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
    
    def new
      content_type = params[:content_type]
      af_model = retrieve_af_model(content_type)
      if af_model
        if(params[:label].include? "image")
          @asset = af_model.load_instance(params[:id])
          inserted_node, new_node_index = @asset.insert_new_node('image', opts={})
          apply_depositor_metadata(@asset)
          set_collection_type(@asset, params[:content_type])
          @asset.save
        else
	  parent_id = (params.keys.include?("subcollection_id") ? params[:subcollection_id] : params[:collection_id])
          create_and_save_component(params[:label], content_type, parent_id)
        end
      end
      redirect_to url_for(:action=>"edit", :controller=>"catalog", :label => params[:label], :id=>@asset.pid)
    end
        
#    def select
#      @document = Component.load_instance(params[:id])
#      @document.update_indexed_attributes({:main_page=>{0=>params[:selected][:page_id]}})
#      @document.save
#      redirect_to url_for(:action=>"edit", :controller=>"catalog", :id=>@asset.pid)
#    end

    def destroy
      ActiveFedora::Base.load_instance(params[:id]).delete

      flash[:notice]= "Deleted " + params[:id]
      redirect_to url_for(:action => 'index', :controller => "catalog", :label => params[:label], :q => nil , :f => nil)
    end
end
