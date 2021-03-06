require 'mediashelf/active_fedora_helper'
class PagesController < ApplicationController
    include Hydra::AssetsControllerHelper
    include Hydra::FileAssetsHelper  
    include Hydra::RepositoryController  
    include MediaShelf::ActiveFedoraHelper
    include Blacklight::SolrHelper
    include WhiteListHelper
    include Blacklight::CatalogHelper
    include ApplicationHelper
    include PagesControllerHelper
  
    helper :hydra, :metadata, :infusion_view
    
    before_filter :search_session, :history_session
    before_filter :require_fedora, :require_solr
    
    def show
      logger.debug("Page Params: #{params.inspect}")
#      if params.has_key?("field")
#        @response, @document = get_solr_response_for_doc_id
#        pid = @document[:id] ? @document[:id] : @document[:id.to_s]
#        pid ? @page = Page.load_instance_from_solr(pid,@document) : @page = nil
#        result = @document["#{params["field"]}_t"]
#        unless result.nil?
#          if params.has_key?("field_index")
#            result = result[params["field_index"].to_i-1]
#          elsif result.kind_of?(Array)
#            result = result.first
#          end
#        end
#        respond_to do |format|
#          format.html     { render :text=>result }
#          format.textile  { render :text=> white_list( RedCloth.new(result, [:sanitize_html]).to_html ) }
#        end
#      else
        redirect_to :controller=>"catalog", :action=>"show", :exhibit_id => params[:exhibit_id], :f => params[:f], :render_search => params[:render_search], :viewing_context => params[:viewing_context]
#      end
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
        af_model = Page
      end
      @document = af_model.find(params[:id])
      
      updater_method_args = prep_updater_method_args(params)
      puts "Update_method: #{updater_method_args.inspect}"
      # this will only work if there is only one datastream being updated.
      # once ActiveFedora::MetadataDatastream supports .update_datastream_attributes, use that method instead (will also be able to pass through params["asset"] as-is without usin prep_updater_method_args!)
      result = @document.update_indexed_attributes(updater_method_args[:params], updater_method_args[:opts])
      puts "Result: #{result.inspect}"
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

    def create
      unless params.has_key?(:Filedata)
        raise "No file to process"
      end
      if !params[:container_id].nil? && params[:Filedata]
#        af_base =  ActiveFedora::Base.find(params[:container_id])
#        af_model = retrieve_af_model(params[:content_type]) #retrieve_af_model( af_base.relationships[:self][:has_model].first.split(":")[-1] )
#        logger.debug "#########: af_model = #{af_model.to_s}"
        generic_content_object = Page.load_instance(params[:container_id])
        generic_content_object.update_indexed_attributes({[:name]=>{"0"=>params[:Filename].sub(".jpg", "")}})
        item_pid = generic_content_object.item.first.pid
        item_obj = Component.load_instance(item_pid)
	image = ''
	img_term = []
        if(item_obj.member_of.first.instance_of? Component)
          image = 'image'
          img_term = [:item, :daogrp, :daoloc, :daoloc_href]
        else
          image = 'subcol_image'
          img_term = [:collection, :daogrp, :daoloc, :daoloc_href]
        end
        inserted_node, new_node_index = item_obj.insert_new_node(image, opts={})
	item_obj.save
	no_of_images = 0
        if(item_obj.methods.contains? "parts")
	  no_of_images = item_obj.parts.size
        end
        item_obj.update_indexed_attributes ({img_term=>{"#{(no_of_images-1).to_s}"=>params[:Filename].sub(".jpg", "")}} )
        item_obj.save
        generic_content_object.content={:file => params[:Filedata], :file_name => params[:Filename]}
        logger.debug "#########: set the content"
        generic_content_object.save
        logger.debug "#########: saved #{generic_content_object.pid} with new content #{params[:Filename]}"
#        if af_model == Page
          logger.debug "#########: deriving images"
          generic_content_object.derive_all
          logger.debug "#########: finished deriving images"
#        end   
      end
      render :nothing => true
    end

    def new
      content_type = params[:content_type]
      af_model = retrieve_af_model(content_type)
      if af_model
        if(!params[:item_id].nil?)
          @asset = create_and_save_page(params[:item_id], content_type)
        elsif(!params[:subcollection_id].nil?)
          @asset = create_and_save_page(params[:subcollection_id], content_type)
	end
      end
      redirect_to url_for(:action=>"edit", :controller=>"catalog", :label => params[:label], :id=>@asset.pid, :exhibit_id => params[:exhibit_id], :render_search => params[:render_search], :f => params[:f], :viewing_context => params[:viewing_context])
    end
    
    def review_comments
      @document_fedora = Page.find(params[:id])
      render :partial => "shared/review_comments", :locals=>{:rev=>params[:rev]}
    end

    def destroy
      ActiveFedora::Base.load_instance(params[:id]).delete
      flash[:notice]= "Deleted " + params[:id]
      redirect_to url_for(:action => 'index', :controller => "catalog", :label => params[:label], :q => nil , :f => nil)
    end
end
