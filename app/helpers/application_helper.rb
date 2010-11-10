require 'vendor/plugins/hydra_repository/app/helpers/application_helper.rb'
module ApplicationHelper

  def application_name
    'Hydrangea (Hydra ND Demo App)'
  end

  def generate_pid(key)
    namespace="ARCH-SEASIDE"
    content_model="Lot"
    pid=namespace << ":" << content_model << key
    #pid="changeme:61"
    logger.error ("Pid of the Lot to add relationship: #{pid}")
    return pid
  end

  def asset_available(pid)
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

end
