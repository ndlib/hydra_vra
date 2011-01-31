require 'net/http'
require 'mediashelf/active_fedora_helper'
require "#{RAILS_ROOT}/vendor/plugins/hydra_exhibits/app/models/ead_xml.rb"

class ExhibitsController < CatalogController

  before_filter :initialize_exhibit, :except=>[:index, :new]
  before_filter :require_solr, :require_fedora, :only=>[:new,:index]
  before_filter :set_page_style, :only => :show

  include Hydra::AssetsControllerHelper
  include ApplicationHelper

  helper :hydra, :metadata, :infusion_view
 
  def index
    @exhibits = Exhibit.find_by_solr(:all).hits.map{|result| Exhibit.load_instance_from_solr(result["id"])}
  end

  def new
    content_type = params[:content_type]
    af_model = retrieve_af_model(content_type)
    logger.debug("Afmodel: #{af_model}")
    if af_model
      @exhibit = af_model.new(:namespace=>"RBSC-CURRENCY")
      @exhibit.save      
      apply_depositor_metadata(@exhibit)
      set_collection_type(@exhibit, params[:content_type])
      @exhibit.save
    end
    redirect_to url_for(:action=>"edit", :controller=>"catalog", :label => params[:label], :id=>@exhibit.pid)
  end

  def update_embedded_search
    get_components(params[:content_type],"active_fedora_model_s:Component")
  end

  def add_main_description
    content_type = params[:content_type]
    af_model = retrieve_af_model(content_type)
    logger.debug("Afmodel: #{af_model}")
    if af_model
      @exhibit = af_model.load_instance(params[:id])
      @exhibit.update_indexed_attributes(:main_description=>{"0"=>params[:description_id]})
      @exhibit.save
      response = Hash["updated"=>[]]
      response["updated"] << {"title update"=>params[:description_id]}
      logger.debug("if loop response-> #{response.inspect}")
    end    
    logger.debug("New description id: #{@exhibit.title}, param description id:#{params[:description_id]}")
    render :partial => "exhibits/edit_settings", :locals => {:content => "exhibit", :document_fedora => @exhibit}
  end

  def add_collection
    content_type = params[:content_type]
    af_model = retrieve_af_model(content_type)
    logger.debug("Afmodel: #{af_model}")
    if af_model
      @exhibit = af_model.load_instance(params[:id])      
    end
    @obj =  ActiveFedora::Base.load_instance(params[:collections_id])
    the_model = ActiveFedora::ContentModel.known_models_for( @obj ).first
    if the_model.nil?
      raise "Unknown content type for the object with pid #{@obj.pid}"
    end
    @asset = the_model.load_instance(params[:collections_id])
    @exhibit.collections_append(@asset)
    @exhibit.save    
    render :partial => "exhibits/edit_settings", :locals => {:content => "exhibit", :document_fedora => @exhibit}
  end

  def remove_collection
    content_type = params[:content_type]
    af_model = retrieve_af_model(content_type)
    logger.debug("Afmodel: #{af_model}")
    if af_model
      @exhibit = af_model.load_instance(params[:id])
    end
    @obj =  ActiveFedora::Base.load_instance(params[:collections_id])
    the_model = ActiveFedora::ContentModel.known_models_for( @obj ).first
    if the_model.nil?
      raise "Unknown content type for the object with pid #{@obj.pid}"
    end
    @asset = the_model.load_instance(params[:collections_id])
    @exhibit.collections_remove(@asset)
    @exhibit.save
    render :text => "Removed collections relation successfully."
  end

  def remove_facet_value
    content_type = params[:content_type]
    af_model = retrieve_af_model(content_type)
    logger.debug("Afmodel: #{af_model}")
    if af_model
      @exhibit = af_model.load_instance(params[:id])
    end
    @obj =  ActiveFedora::Base.load_instance(params[:collections_id])
    the_model = ActiveFedora::ContentModel.known_models_for( @obj ).first
    if the_model.nil?
      raise "Unknown content type for the object with pid #{@obj.pid}"
    end
    @asset = the_model.load_instance(params[:collections_id])
    @exhibit..update_indexed_attributes(:main_description=>{params[:index]=>params[:facet_value]})
    @exhibit.save
    render :text => "Removed collections relation successfully."
  end

  def refresh_setting
    content_type = params[:content_type]
    af_model = retrieve_af_model(content_type)
    logger.debug("Afmodel: #{af_model}")
    if af_model
      @asset = af_model.load_instance(params[:id])
    end
    logger.debug("browse_facets: #{@asset.browse_facets}")
    render :partial => "exhibits/edit_settings", :locals => {:content => content_type, :document_fedora => @asset}
  end

  def show
    show_without_customizations
  end

  # Just return nil for exhibit facet limit because we want to display all values for browse links
  def facet_limit_for(facet_field)
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
