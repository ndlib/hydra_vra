require 'net/http'
require 'mediashelf/active_fedora_helper'
require "#{RAILS_ROOT}/vendor/plugins/hydra_exhibits/app/models/ead_xml.rb"

class CollectionsController < CatalogController
  include Hydra::AssetsControllerHelper
  include Hydra::FileAssetsHelper  
  include Hydra::RepositoryController  
  include MediaShelf::ActiveFedoraHelper
  include Blacklight::SolrHelper
  include WhiteListHelper
  include Blacklight::CatalogHelper
  include ApplicationHelper

  helper :hydra, :metadata, :infusion_view

#  before_filter :initialize_collection, :except=>[:index, :new, :update]
  before_filter :require_solr, :require_fedora, :only=>[:show, :edit, :index, :new, :update]
  def index
    @collections = Collection.find_by_solr(:all).hits.map{|result| Collection.load_instance_from_solr(result["id"])}
  end

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
      @asset = af_model.new(:namespace=>"RBSC-CURRENCY")
      @asset.datastreams["descMetadata"].ng_xml = EadXml.collection_template
      apply_depositor_metadata(@asset)
      set_collection_type(@asset, params[:content_type])
      @asset.save
    end
    redirect_to url_for(:action=>"edit", :controller=>"catalog", :label => params[:label], :id=>@asset.pid)
  end


  def show  
    show_without_customizations
  end

   # Look up configged facet limit for given facet_field. If no
  # limit is configged, may drop down to default limit (nil key)
  # otherwise, returns nil for no limit config'ed. 
  def facet_limit_for(facet_field)
    #limits_hash = facet_limit_hash
    #return nil unless limits_hash

    #limit = limits_hash[facet_field]
    #limit = limits_hash[nil] unless limit

    #return limit

    #just return nil since displaying all of them for now
    return nil
  end
  helper_method :facet_limit_for
  # Returns complete hash of key=facet_field, value=limit.
  # Used by SolrHelper#solr_search_params to add limits to solr
  # request for all configured facet limits.
  def facet_limit_hash
    Blacklight.config[:facet][:limits]           
  end
  helper_method :facet_limit_hash

end
