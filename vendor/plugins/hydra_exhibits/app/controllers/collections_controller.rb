require 'net/http'

class CollectionsController < ApplicationController
  caches_page :index, :show

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
    @sub_collections = sub_collections_in_collection

    #call collection.essays once since querying solr everytime on inbound relationship
    essays = @collection.essays
    if essays.any?
      @essay = essays.first
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

  def sub_collections_in_collection
    sub_collections = []
    @collection.sub_collections_ids.each do |genre_id|
      #pid = genre_id.split('/').last
      genres << GenreForm.load_instance_from_solr(genre_id)
    end
    genres
  end
end
