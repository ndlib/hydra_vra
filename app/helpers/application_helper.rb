require "#{RAILS_ROOT}/vendor/plugins/hydra_repository/lib/mediashelf/active_fedora_helper.rb"

module ApplicationHelper

  include MediaShelf::ActiveFedoraHelper
  
  def application_name
    'Hydrangea (Hydra ND Demo App)'
  end

  def generate_pid(key, content_model)
    namespace="ARCH-SEASIDE"
    #content_model="Lot"
    pid=namespace << ":" << (content_model.blank? ? '' : content_model) << key
    #pid="changeme:61"
    logger.debug("Pid to look up or generate: #{pid}")
    return pid
  end

  def asset_available(pid, content_model)
    content_model_type = nil
    args = {:id=> pid}
    opts = {}
    #content_model="Lot"
    #object = content_model.split('::').inject(Kernel) {|scope, const_name|
    #content_model_type = scope.const_get(const_name)}
    af_model = retrieve_af_model(content_model)
    raise "Content model #{content_model} is not of type ActiveFedora:Base" unless af_model
    raise "Content model #{af_model} does not implement find_by_fields_by_solr" unless af_model.respond_to?(:find_by_fields_by_solr)
    results = af_model.find_by_fields_by_solr(args,opts)
    if results.nil? || results.hits.nil? || results.hits.empty? || results.hits.first[SOLR_DOCUMENT_ID].nil?
      #logger.debug("Result is empty need to create new obj")
      return false
    else
      #logger.debug("result from solr: #{results.inspect}")
      return true
    end

    return false
  end

end
