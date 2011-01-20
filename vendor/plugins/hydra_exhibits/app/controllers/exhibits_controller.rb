require 'net/http'
require 'mediashelf/active_fedora_helper'
require "#{RAILS_ROOT}/vendor/plugins/hydra_exhibits/app/models/ead_xml.rb"

class ExhibitsController < CatalogController

  before_filter :initialize_exhibit, :except=>[:index, :new]
  before_filter :require_solr, :require_fedora, :only=>[:new]

  include Hydra::AssetsControllerHelper

  helper :hydra, :metadata, :infusion_view
 

  def initialize_exhibit
    require_fedora
    require_solr
    params[:exhibit_id] ? exhibit_id = params[:exhibit_id] : exhibit_id = params[:id]
    @exhibit = Exhibit.load_instance_from_solr(exhibit_id)
    @browse_facets = @exhibit.browse_facets
    @facet_subsets_map = @exhibit.facet_subsets_map
    @selected_browse_facets = get_selected_browse_facets(@browse_facets) 
    #subset will be nil if the condition fails
    @subset = @facet_subsets_map[@selected_browse_facets] if @selected_browse_facets.length > 0 && @facet_subsets_map[@selected_browse_facets]
    #call exhibit.discriptions once since querying solr everytime on inbound relationship
    if browse_facet_selected?(@browse_facets)
      @subset.nil? ? @descriptions = [] : @descriptions = @subset.descriptions
    else
      #use exhibit descriptions
      @descriptions = @exhibit.descriptions
    end
    logger.debug("Description: #{@descriptions}, Subset:#{@subset.inspect}")
    @extra_controller_params ||= {}
    exhibit_members_query = @exhibit.build_members_query
    lucene_query = build_lucene_query(params[:q])
    lucene_query = "#{exhibit_members_query} AND #{lucene_query}" unless exhibit_members_query.empty?
    (@response, @document_list) = get_search_results( @extra_controller_params.merge!(:q=>lucene_query))
    @browse_response = @response
    @browse_document_list = @document_list
  end



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

  def update_attributes
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
