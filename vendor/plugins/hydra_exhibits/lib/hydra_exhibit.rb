module HydraExhibit

  autoload :Configurable, 'configurable'
  extend Configurable

  class << self
    #attr_accessor :solr, :solr_config
  end

  def self.init
    puts "HydraExhibit: initialized with HydraExhibit.config: #{HydraExhibit.config.inspect}"
    logger.error("HydraExhibit: initialized with HydraExhibit.config: #{HydraExhibit.config.inspect}")
  end

  def self.logger
    RAILS_DEFAULT_LOGGER
  end
  
  # returns the full path the the HydraExhibit plugin installation
  def self.root
    @root ||= File.expand_path File.join(__FILE__, '..', '..')
  end
  
  # Searches Rails.root then Blacklight.root for a valid path
  # returns a full path if a valid path is found
  # returns nil if nothing is found.
  # First looks in Rails.root, then Blacklight.root
  #
  # Example:
  # full_path_to_solr_marc_jar = Blacklight.locate_path 'solr_marc', 'SolrMarc.jar'
  
  def self.locate_path *subpath_fragments
    subpath = subpath_fragments.join('/')
    base_match = [Rails.root, HydraExhibit.root].find do |base|
      File.exists? File.join(base, subpath)
    end
    File.join(base_match.to_s, subpath) if base_match
  end
  
end