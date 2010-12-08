class GenreFormsController < ApplicationController
  caches_page :index, :show

  before_filter :instantiate_related_objects

  def index
    @genre_forms = genres_in_collection
  end

  def show
    @genre_form = GenreForm.load_instance_from_solr(params[:id])
    if @genre_form.essays.any?
      @essay = @genre_form.essays.first
    end

    @genres = genres_in_collection

    @highlighted_items = []
    @genre_form.highlighted_in_genre_ids.each do |item_id|
      @highlighted_items << Item.load_instance_from_solr(item_id)
    end
  end

  # Need to change to return array of paths to execute in order to load cache
  def clear_cache
    cleared_paths = []
    begin
      if params[:id]
        @genre = GenreForm.load_instance_from_solr(params[:id])
        expire_page collection_path(@genre.parent_id)
        cleared_paths << collection_path(@genre.parent_id)
        cleared_paths << get_genre_cache_paths(@genre.parent_id, @genre, true)
      else
        @genres = genres_in_collection
        unless @genres.nil? || @genres.empty?
          collection_id = @genres.first.parent_id
          expire_page collection_path(collection_id)
          cleared_paths << collection_path(collection_id)

          @genres.each do |genre|
            cleared_paths << get_genre_cache_paths(collection_id, genre, true)
          end
        end
      end
    rescue Exception => e
      render :json => "Failed to clear genre cache: #{e.message}"
    end
    render :json => cleared_paths
  end

  def cached_paths
    paths = []
    begin
      if params[:id]
        @genre = GenreForm.load_instance_from_solr(params[:id])
        paths << collection_path(@genre.parent_id)
        paths << get_genre_cache_paths(@genre.parent_id, @genre)
      else
        @genres = genres_in_collection
        unless @genres.nil? || @genres.empty?
          collection_id = @genres.first.parent_id
          paths << collection_path(collection_id)

          @genres.each do |genre|
            clear_genre_cache(collection_id,genre)
            paths << get_genre_cache_paths(collection_id, genre)
          end
       end
      end
    rescue Exception => e
      render :json => "Failed to get genre cached paths: #{e.message}"
    end
    render :json => paths
  end

  private

  # Return an array of all paths that need to be executed in order to reload the cache
  def get_genre_cache_paths(collection_id, genre, clear_cache=false)
    cache_paths = []
    genre_path = collection_genre_form_path(:id => genre.id, :collection_id => collection_id)
    expire_page genre_path if clear_cache
    cache_paths << genre_path
    genre.essays.each do |essay|
      expire_page collection_essay_path(collection_id,essay.id) if clear_cache
      cache_paths << collection_essay_path(collection_id,essay.id,:genre_form_id => genre.id)
    end
    cache_paths
  end

  def instantiate_related_objects
    params[:collection_id] ? @collection = Collection.load_instance_from_solr(params[:collection_id]) : false
  end

  def genres_in_collection
    genres = []
    @collection.genre_forms_ids.each do |genre_id|
      genres << GenreForm.load_instance_from_solr(genre_id)
    end
    genres
  end
end
