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
        pid ? @component = Component.load_instance_from_solr(pid,@document) : @component = nil
        result = @document["#{params["field"]}_t"]
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
        redirect_to :controller=>"catalog", :action=>"show", :label=>params[:label], :exhibit_id => params[:exhibit_id], :render_search => params[:render_search], :f => params[:f], :viewing_context => params[:viewing_context]
      end
    end
    
    # Uses the update_indexed_attributes method provided by ActiveFedora::Base
    # This should behave pretty much like the ActiveRecord update_indexed_attributes method
    # For more information, see the ActiveFedora docs.

    def update
      af_model = retrieve_af_model(params[:content_type])
      unless af_model 
        af_model = Component
      end
      @document = af_model.find(params[:id])
#      if(params.has_keys?"description_id")
#        @asset = af_model.load_instance(params[:id])
#        @asset.update_indexed_attributes({:main_page=>{0=>params[:description_id]}})
#        @asset.save
#	redirect_to url_for(:action=>"edit", :controller=>"catalog", :id=>@asset.pid, :exhibit_id => params[:exhibit_id], :render_search => params[:render_search], :f => params[:f], :viewing_context => params[:viewing_context])
      if((params.has_keys?"field_selectors") && (params[:field_selectors].has_keys?"properties") && (params[:field_selectors][:properties].has_keys?"subcollection_id"))
        @asset = af_model.load_instance(params[:id])
        @asset.update_indexed_attributes({:subcollection_id=>{"0"=>params[:asset][:properties][:subcollection_id].first.second}})
        @asset.save
	redirect_to url_for(:action=>"edit", :controller=>"catalog", :id=>@asset.pid, :exhibit_id => params[:exhibit_id], :render_search => params[:render_search], :f => params[:f], :viewing_context => params[:viewing_context])
      else
	if((params.has_keys?"field_selectors") && ((params[:field_selectors]).has_keys?"descMetadata"))
	  if(params[:field_selectors][:descMetadata].has_keys?"item_did_unitid")
            @document.update_indexed_attributes({:item_id=>{"0"=>params[:asset][:descMetadata][:item_did_unitid].first.second}})
	    @document.save
	  end
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
      redirect_to url_for(:action=>"edit", :controller=>"catalog", :label => params[:label], :id=>@asset.pid, :exhibit_id => params[:exhibit_id], :render_search => params[:render_search], :f => params[:f], :viewing_context => params[:viewing_context])
    end

    def review_comments
      @document_fedora = Component.find(params[:id])
      render :partial => "shared/review_comments", :locals=>{:rev=>params[:rev]}
    end

    def destroy
      ActiveFedora::Base.load_instance(params[:id]).delete

      flash[:notice]= "Deleted " + params[:id]
      redirect_to url_for(:action => 'index', :controller => "catalog", :label => params[:label], :q => nil , :f => nil)
    end
end
