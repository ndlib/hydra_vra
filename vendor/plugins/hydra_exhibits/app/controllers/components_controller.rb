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
  
    helper :hydra, :metadata, :infusion_view
    
    before_filter :search_session, :history_session
    before_filter :require_fedora, :require_solr
    
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
        af_model = HydrangeaArticle
      end
      @document = af_model.find(params[:id])
      
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
    
    def new
      content_type = params[:content_type]
      af_model = retrieve_af_model(content_type)
      if af_model
        if(params[:label].include? "item")
          @asset = af_model.new(:namespace=>"RBSC-CURRENCY")
          @asset.datastreams["descMetadata"].ng_xml = EadXml.item_template
          apply_depositor_metadata(@asset)
          set_collection_type(@asset, params[:content_type])
          @asset.update_indexed_attributes({:component_type=>{0=>"item"}})
	  @asset.members_append(params[:subcollection_id])
          @asset.save
        elsif(params[:label].include? "subcollection")
          @asset = af_model.new(:namespace=>"RBSC-CURRENCY")
          @asset.datastreams["descMetadata"].ng_xml = EadXml.subcollection_template
          apply_depositor_metadata(@asset)
          set_collection_type(@asset, params[:content_type])
          @asset.update_indexed_attributes({:component_type=>{0=>"subcollection"}})
	  @asset.member_of_append(params[:collection_id])
          @asset.save
        elsif(params[:label].include? "image")
          @asset = af_model.load_instance(params[:id])
          inserted_node, new_node_index = @asset.insert_new_node('image', opts={})
          apply_depositor_metadata(@asset)
          set_collection_type(@asset, params[:content_type])
          @asset.save
        end
      end
      redirect_to url_for(:action=>"edit", :controller=>"catalog", :label => params[:label], :id=>@asset.pid)
    end
    
    def destroy
      ActiveFedora::Base.load_instance(params[:id]).delete

      flash[:notice]= "Deleted " + params[:id]
      redirect_to url_for(:action => 'index', :controller => "catalog", :label => params[:label], :q => nil , :f => nil)
    end
#  include Hydra::AssetsControllerHelper
#  include Hydra::FileAssetsHelper
#  include Hydra::RepositoryController
#  include MediaShelf::ActiveFedoraHelper
#  include Blacklight::SolrHelper
#  include WhiteListHelper
#  include Blacklight::CatalogHelper
#  include ApplicationHelper
#
#  helper :hydra, :metadata, :infusion_view
#  before_filter :require_fedora
#  before_filter :require_solr, :only=>[:index, :new, :create, :show, :destroy]
#
#  def check_required_params(required_params)
#  not_found = ""
#  if required_params.respond_to?(:each)
#    required_params.each do |param|
#      not_found = not_found.concat("#{param} parameter is required\n") unless params.has_key?(param)
#    end
#  end
#  raise not_found if not_found.length > 0
#  end
#
#  def index
#    logger.error("Index param: #{params.inspect}")
#    if params[:layout] == "false"
#      # action = "index_embedded"
#      layout = false
#    end
#    @component=Component.load_instance(params[:component_id])
#    if(@component.pid.include? "SUBCOLLECTION")
#      render :partial=>"components/index", :layout=>layout
#    elsif(@component.pid.include? "ITEM")
#      render :partial=>"components/index", :layout=>layout
#    end
#  end
##  def new
##    render :partial=>"new", :layout=>false
##  end
#  def new
#    content_type = params[:content_type]
#    af_model = retrieve_af_model(content_type)
#    if af_model
#      if(content_type.include? "item")
#        @asset = af_model.new(:component_level => "c02")
#        @asset.datastreams["descMetadata"].ng_xml = EadXml.item_template
#        apply_depositor_metadata(@asset)
#        set_collection_type(@asset, params[:content_type])
#        @asset.save
#      elsif(content_type.include? "subcomponent")
#        @asset = af_model.new(:component_level => "c01")
#        @asset.datastreams["descMetadata"].ng_xml = EadXml.collection_template
#        apply_depositor_metadata(@asset)
#        set_collection_type(@asset, params[:content_type])
#        @asset.save
#      end
#    end
#    redirect_to url_for(:action=>"edit", :controller=>"catalog", :id=>@asset.pid)
#  end
#  def create
#    attributes = params
#    unless attributes.has_key?(:label)
#      attributes[:label] = "subcollection"
#    end
#    key = "#{attributes[:label].upcase}_#{params[:key]}"
#    pid = generate_pid(key, nil)
#    if(pid.include? "ITEM")
#      if(!asset_available(pid, nil))
#        @item= Component.new(:pid=>pid, :component_level => "c02")
#        @item.datastreams["descMetadata"].ng_xml = EadXml.item_template
#        apply_depositor_metadata(@item)
#        @item.save
#        @item.update_indexed_attributes(attributes)
#      else
#        @item=load_instance("Component", pid)
#      end
#      if(attributes.has_key?(:collection_id))
#        collection_pid = generate_pid("SUBCOLLECTION_#{attributes[:collection_id]}",nil)
#        @item.subcomponents_append(params[collection_pid)
#      end
#    elsif(pid.include? "SUBCOLLECTION")
#      if(!asset_available(pid, nil))
#        @subcollection= af_model.new(:pid=>pid, :component_level => "c01")
#        @subcollection.datastreams["descMetadata"].ng_xml = EadXml.collection_template
#        apply_depositor_metadata(@subcollection)
#        @subcollection.save
#        @subcollection.update_indexed_attributes(attributes)
#      else
#        @subcollection=load_instance("Component", pid)
#      end
#      render :partial=>"components/index", :locals=>{"components".to_sym =>@object.component_list}, :layout=>false
#    end
#  end
#
#  def destroy
##    check_required_params([:content_model,:id,:content_type,:pid])
##    @lot=load_instance(params[:content_model],params[:id])
##    remove_named_relationship(@lot, params[:building_content_type], params[:building_pid])
##    render :text => "Deleted #{params[:id]} from realtionships from #{params[:building_pid]}."
#  end
#
##  def show
##    if params.has_key?("field")
##      @response, @document = get_solr_response_for_doc_id       # @document = SolrDocument.new(@response.docs.first)
##      result = @document["#{params["field"]}_t"]
##      # document_fedora = SaltDocument.load_instance(params[:id])
##      # result = document_fedora.datastreams_in_memory[params["datastream"]].send("#{params[:field]}_values")
##      unless result.nil?
##        if params.has_key?("field_index")
##          result = result[params["field_index"].to_i-1]
##        elsif result.kind_of?(Array)
##          result = result.first
##        end
##      end
##      respond_to do |format|
##        format.html     { render :text=>result }
##        format.textile  { render :text=> white_list( RedCloth.new(result, [:sanitize_html]).to_html ) }
##      end
##    else
##      redirect_to :controller=>"catalog", :action=>"show"
##    end
##  end
#  def show
#    redirect_to(:action => 'index', :q => nil , :f => nil)
#  end
end
