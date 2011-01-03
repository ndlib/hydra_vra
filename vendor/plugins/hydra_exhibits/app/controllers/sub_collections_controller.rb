require 'net/http'
require 'mediashelf/active_fedora_helper'
require "#{RAILS_ROOT}/vendor/plugins/hydra_exhibits/app/models/ead_xml.rb"

class SubCollectionsController < ApplicationController

  #caches_page :index, :show

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
    #@browse_facets = collection_browse_facets
    @extra_controller_params ||= {}
    (@response, @document_list) = get_search_results( @extra_controller_params.merge!(:q=>build_lucene_query(params[:q])) )
    @browse_facets = @collection.browse_facets

    #call collection.discriptions once since querying solr everytime on inbound relationship
    descriptions = @collection.descriptions
    if descriptions.any?
      @description = essays.first
    end
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

  private

  #returns an array of selected display facets from Blacklight marked for browse navigation 
#  def collection_browse_facets
#    @extra_controller_params ||= {}
#    (@response, @document_list) = get_search_results( @extra_controller_params.merge!(:q=>build_lucene_query(params[:q])) )

#    browse_facets = []
#    @collection.browse_facets.each do |browse_facet|
#      (browse_facet.is_a? Hash) ? solr_fname = browse_facet.keys.first : solr_fname = browse_facet.to_s
#      display_facet = @response.facets.detect {|f| f.name == solr_fname}
#      unless display_facet.nil?
#        logger.debug("Display facet found: #{display_facet.inspect}")
#        browse_facets << display_facet
#        if browse_facet.is_a? Hash
#          display_second_facet = @response.facets.detect {|f| f.name == browse_facet[solr_fname]}
#          (browse_facet[solr_fname].is_a? Hash) ? solr_second_fname = browse_facet[solr_fname].keys.first : solr_second_fname = browse_facet[solr_fname].to_s
#          unless display_second_facet.nil?
#            browse_facets << display_second_facet
#          else
#            logger.debug("display second facet is nil for #{solr_second_fname}")
#          end
#        end
#      else 
#        logger.debug("display facet is nil for #{solr_fname}")
#      end
#    end
#    browse_facets
#  end
end
