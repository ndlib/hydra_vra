require 'mediashelf/active_fedora_helper'

class LotsController < ApplicationController
  
  include Hydra::AssetsControllerHelper
  include Hydra::FileAssetsHelper  
  include Hydra::RepositoryController  
  include MediaShelf::ActiveFedoraHelper
  include Blacklight::SolrHelper
  include WhiteListHelper
  include Blacklight::CatalogHelper

  helper :hydra, :metadata, :infusion_view
  before_filter :require_fedora
  before_filter :require_solr, :only=>[:index, :create, :show, :destroy]

  def check_required_params(required_params)
  not_found = ""
  if required_params.respond_to?(:each)
    required_params.each do |param|
      not_found = not_found.concat("#{param} parameter is required\n") unless params.has_key?(param)
    end
  end
  raise not_found if not_found.length > 0
  end

  def index
    logger.error("Index param: #{params.inspect}")
    if params[:layout] == "false"
      # action = "index_embedded"
      layout = false
    end
    @building=Building.load_instance(params[:building_id])
    logger.error("Building pid: #{@building.pid}")
    render :partial=>"lots/index", :layout=>layout
  end
  
  def new
    render :partial=>"new", :layout=>false
  end
  
  def create
    attributes = params
    unless attributes.has_key?(:label)
      attributes[:label] = "Lot"
    end
    lot_pid=  generate_pid(params[:key])
    if (!lot_available(lot_pid))
      attributes["pid"]=  lot_pid
      attributes.merge!({:new_object=>true})
      if attributes.has_key?("pid")
        attributes.merge!({:pid=>attributes["pid"]})
        attributes[:pid] = attributes["pid"]
      end
      attributes[:pid] = attributes[:pid]["0"] if attributes.has_key?(:pid) && attributes[:pid].is_a?(Hash) && attributes[:pid].has_key?("0")
      @lot = create_instance("Lot", attributes)
      apply_depositor_metadata(@lot)
      @lot.save
      @lot.update_indexed_attributes(attributes)
      logger.debug "Created Lot with pid #{@lot.pid}."
    else
      logger.debug "Lot is create already. So load the obj"
      @lot=load_instance("Lot",lot_pid)
    end
    add_named_relationship(params[:building_content_type], params[:building_pid])
    @building=Building.load_instance(params[:building_pid])
    render :partial=>"lots/index", :locals=>{"lots".to_sym =>@object.lot_list}, :layout=>false
    #render :text => "Successfull added relationship betweeb #{params[:building_pid]} and #{@lot.pid}."
  end

  def destroy
    check_required_params([:content_model,:id,:building_content_type,:building_pid])
    @lot=load_instance(params[:content_model],params[:id])
    remove_named_relationship(params[:building_content_type], params[:building_pid])
    render :text => "Deleted #{params[:id]} from realtionships from #{params[:building_pid]}."
  end

  def lot_available(pid)
    content_model_type = nil
    args = {:id=> pid}
    opts = {}
    content_model="Lot"
    object = content_model.split('::').inject(Kernel) {|scope, const_name|
    content_model_type = scope.const_get(const_name)}
    unless content_model_type.nil?
      #logger.debug "#{content_model_type} methods: #{content_model_type.class.methods.sort.inspect}"
      raise "Content model Lot does not implement find_by_fields_by_solr" unless content_model_type.respond_to?(:find_by_fields_by_solr)
      results = content_model_type.find_by_fields_by_solr(args,opts)
      if results.nil? || results.hits.nil? || results.hits.empty? || results.hits.first[SOLR_DOCUMENT_ID].nil?
        #logger.debug("Result is empty need to create new obj")
        return false
      else
        #logger.debug("result from solr: #{results.inspect}")
        return true
      end
    end
    return false
  end

  def create_instance(content_model,attributes={})
    content_model.split('::').inject(Kernel) {|scope, const_name|
    scope.const_get(const_name)}.new(attributes)
  end

  def add_named_relationship(target_content_type, target_pid)
    if @lot.nil?
      raise "Lot object with content model"
    else
      if @lot.respond_to?(:add_named_relationship)
        if @lot.is_named_relationship?(target_content_type,true)
          #check if :type is defined for this relationship, if so instantiate with that type
          unless @lot.named_relationship_type(target_content_type).nil?
          	@object = load_instance(@lot.named_relationship_type(target_content_type).to_s,target_pid)
          end
          #check object for added relationship
          if @object.nil?
            raise "Unable to find fedora object with pid #{target_pid} to add to pid: #{@lot.pid} as #{target_content_type}"
          else
        	@lot.add_named_relationship(target_content_type,@object)
        	@lot.save
          end
        else
          raise "outbound relationship: #{target_content_type} does not exist for content model: #{@lot.class}"
        end
      else
        raise "Content model: #{@lot.class} does not implement add_named_relationship"
      end
    end
  end



  def remove_named_relationship(target_content_type, target_pid)
    if @lot.nil?
      raise "Lot object with content model"
    else
      if @lot.respond_to?(:remove_named_relationship)
        if @lot.is_named_relationship?(target_content_type,true)
          #check object for added relationship
          #check if :type is defined for this relationship, if so instantiate with that type
          unless @lot.named_relationship_type(target_content_type).nil?
            @object = load_instance(@lot.named_relationship_type(target_content_type).to_s,target_pid)
          end
          if @object.nil?
            raise "Fedora object not found for content model #{@lot.named_relationship_type(target_content_type).to_s} and pid #{target_pid}"
          else
        	@lot.remove_named_relationship(target_content_type,@object)
        	@lot.save
          end
        else
          raise "Outbound named relationship #{target_content_type} does not exist for Content model: #{@lot.class}"
        end
      else
        raise "Content model: #{@lot.class} does not implement remove_named_relationship"
      end
    end
  end

  def load_instance(content_model, pid)
    begin
      #use reflection to instantiate object
      object = content_model.split('::').inject(Kernel) {|scope, const_name|
      scope.const_get(const_name)}.load_instance(pid)
    rescue
      raise "Fedora Object not found for content model #{content_model} and pid #{pid}"
    end

    #check that has model matches class
    object.assert_kind_of_model('Fedora Object', object, object.class)
    return object
  end

  def generate_pid(key)
    namespace="ARCH-SEASIDE"
    content_model="Lot"
    pid=namespace << ":" << content_model << key
    #pid="changeme:61"
    logger.error ("Pid of the Lot to add relationship: #{pid}")
    return pid
  end
  # Common destroy method for all AssetsControllers
  
  def show
     redirect_to(:action => 'index', :q => nil , :f => nil)
  end
end
