require 'net/http'
require 'mediashelf/active_fedora_helper'
require "#{RAILS_ROOT}/vendor/plugins/hydra_exhibits/app/models/ead_xml.rb"

class ExhibitsController < CatalogController

  before_filter :initialize_exhibit, :except=>[:index, :new]
  before_filter :require_solr, :require_fedora, :only=>[:new,:index]

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
    get_search_results_from_params(params[:content_type])
  end

  def add_main_essay
    content_type = params[:content_type]
    af_model = retrieve_af_model(content_type)
    logger.debug("Afmodel: #{af_model}")
    if af_model
      @exhibit = af_model.load_instance(params[:id])
      @exhibit.update_indexed_attributes(:main_description=>{"0"=>params[:essay_id]})
      @exhibit.save
      response = Hash["updated"=>[]]
      response["updated"] << {"title update"=>params[:essay_id]}
      logger.debug("if loop response-> #{response.inspect}")
    end    
    logger.debug("New description id: #{@exhibit.title}, param essay id:#{params[:essay_id]}")
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

  def browse_facet_selected?(browse_facets)
    browse_facets.each do |facet|
      return true if params[:f] and params[:f][facet]
    end
    return false
  end
  helper_method :browse_facet_selected?

  def get_selected_browse_facets(browse_facets)
    selected = {}
    if params[:f]
      browse_facets.each do |facet|
        selected.merge!({facet.to_sym=>params[:f][facet].first}) if params[:f][facet]
      end
    end
    selected
  end
  helper_method :get_selected_browse_facets
end
