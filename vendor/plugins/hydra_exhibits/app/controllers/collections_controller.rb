require 'net/http'
require 'mediashelf/active_fedora_helper'
require "#{RAILS_ROOT}/vendor/plugins/hydra_exhibits/app/models/ead_xml.rb"

class CollectionsController < CatalogController

  before_filter :initialize_collection, :except=>[:index]

  def initialize_collection
    params[:collection_id] ? collection_id = params[:collection_id] : collection_id = params[:id]
    @collection = Collection.load_instance_from_solr(collection_id)
    @browse_facets = @collection.browse_facets
    @facet_subsets_map = @collection.facet_subsets_map
    @selected_browse_facets = get_selected_browse_facets(@browse_facets) 
    #subset will be nil if the condition fails
    @subset = @facet_subsets_map[@selected_browse_facets] if @selected_browse_facets.length > 0 && @facet_subsets_map[@selected_browse_facets]
    #call collection.discriptions once since querying solr everytime on inbound relationship
    if browse_facet_selected?(@browse_facets)
      @subset.nil? ? @descriptions = [] : @descriptions = @subset.descriptions
    else
      #use collection descriptions
      @descriptions = @collection.descriptions
    end
    @extra_controller_params ||= {}
    (@response, @document_list) = get_search_results( @extra_controller_params.merge!(:q=>build_lucene_query(params[:q])) )
    @browse_response = @response
  end

  #def index
  #  super
    #render :partial=>"catalog/index"
  #end
  #def index
  #  @collections = Collection.find_by_solr(:all).hits.map{|result| Collection.load_instance_from_solr(result["id"])}
  #  if @collections.size == 1
  #    #just redirect to that collection if only one
  #    redirect_to collection_path(@collections.first.pid)
  #  else
  #    render :layout => 'rbsc'
  #  end
  #  super
  #end

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
