require 'net/http'
require 'mediashelf/active_fedora_helper'
require "#{RAILS_ROOT}/vendor/plugins/hydra_exhibits/app/models/ead_xml.rb"

class CollectionsController < ApplicationController

  caches_page :index, :show

  include MediaShelf::ActiveFedoraHelper
  include Blacklight::SolrHelper
  include Hydra::RepositoryController
  include Hydra::AccessControlsEnforcement

  before_filter :require_fedora, :require_solr

  def index
    @collections = Collection.find_by_solr(:all).hits.map{|result| Collection.load_instance_from_solr(result["id"])}
    if @collections.size == 1
      #just redirect to that collection if only one
      redirect_to collection_path(@collections.first.pid)
    else
      render :layout => 'rbsc'
    end
  end

  def show
    @collection = Collection.load_instance_from_solr(params[:id])
    @members = members_of_collection

    #call collection.discriptions once since querying solr everytime on inbound relationship
    descriptions = @collection.descriptions
    if descriptions.any?
      @description = essays.first
    end
  end

  # Need to change to return array of paths to execute in order to load cache
  def clear_cache
    begin
      expire_page collections_path
      cache_paths = []
      if params[:id]
        clear_collection_cache(params[:id])
        cache_paths = collection_cache_paths(collection_id)
      else
        collection_ids = Collection.find_by_solr(:all).hits.map{|result| result["id"]}
        collection_ids.each do |collection_id|
          clear_collection_cache(collection_id)
          cache_paths << collection_cache_paths(collection_id)
        end
      end
    rescue Exception => e
      render :json => "Failed to clear cache: #{e.message}"
    end
    render :json => cache_paths
  end

  def cached_paths
    paths = []
    paths << collections_path
    if params[:id]
      paths = collection_cache_paths(collection_id)
    else
      collection_ids = Collection.find_by_solr(:all).hits.map{|result| result["id"]}
      collection_ids.each do |collection_id|
        clear_collection_cache(collection_id)
        paths << load_collection_cache_paths(collection_id)
      end
    end
    paths
  end

   # Look up configged facet limit for given facet_field. If no
  # limit is configged, may drop down to default limit (nil key)
  # otherwise, returns nil for no limit config'ed. 
  def facet_limit_for(facet_field)
    limits_hash = facet_limit_hash
    return nil unless limits_hash

    limit = limits_hash[facet_field]
    limit = limits_hash[nil] unless limit

    return limit
  end
  helper_method :facet_limit_for
  # Returns complete hash of key=facet_field, value=limit.
  # Used by SolrHelper#solr_search_params to add limits to solr
  # request for all configured facet limits.
  def facet_limit_hash
    Blacklight.config[:facet][:limits]           
  end
  helper_method :facet_limit_hash

  private

  def clear_collection_cache(collection_id)
    expire_page collection_path(collection_id)
    @collection = Collection.load_instance_from_solr(collection_id)
    genres_in_collection.each do |genre|
      expire_page collection_genre_form_path(:id => genre.id, :collection_id => collection_id)
      genre.essays.each do |essay|
        expire_page collection_essay_path(collection_id,essay.id)
      end
    end

    @collection.essays.each do |essay|
      expire_page collection_essay_path(collection_id,essay.id)
    end
  end

#  def cache_path(path)
#    url = URI.parse(path)
#    puts "\r\n\r\n\r\n#{url.inspect}\r\n\r\n\r\n"
#    req = Net::HTTP::Get.new(url.path)
#    res = Net::HTTP.start(url.host, url.port) {|http|
#      http.request(req)
#    }
#    #response, body = Net::HTTP.get(URI.parse(path))
#    self.class.cache_page res.body, path
#  end

  # Return an array of all paths that need to be executed in order to reload the cache
  def collection_cache_paths(collection_id)
    cache_paths = []
    cache_paths << collection_path(collection_id)
    @collection = Collection.load_instance_from_solr(collection_id)
    genres_in_collection.each do |genre|
      cache_paths << collection_genre_form_path(:id => genre.id, :collection_id => collection_id)
      genre.essays.each do |essay|
        cache_paths << collection_essay_path(collection_id,essay.id,:genre_form_id => genre.id)
      end
    end

    @collection.essays.each do |essay|
      cache_paths << collection_essay_path(collection_id,essay.id)
    end
    cache_paths
  end

  def members_of_collection
    members = []
    @extra_controller_params ||= {}
    (@response, @document_list) = get_search_results( @extra_controller_params.merge!(:q=>build_lucene_query(params[:q])) )

    @collection.browse_facets.each do |solr_fname|
      display_facet = @response.facets.detect {|f| f.name == solr_fname}
      unless display_facet.nil?
        display_facet.items.each do |item|
          members << item.value
        end
      end
    end
    members
  end
end
