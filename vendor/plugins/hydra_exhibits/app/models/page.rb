require 'hydra'

class Page < ActiveFedora::Base
  include Hydra::GenericImage
  include Hydra::ModelMethods
  
  has_bidirectional_relationship  "item",   :is_part_of, :has_part
  has_bidirectional_relationship  "essays", :is_description_of, :has_description
  
  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 

  has_metadata :name => "descMetadata", :type => ActiveFedora::QualifiedDublinCoreDatastream
  
  # A place to put extra metadata values
  has_metadata :name => "properties", :type => ActiveFedora::MetadataDatastream do |m|
    m.field 'collection', :string
    m.field 'depositor', :string
    m.field 'title', :string
  end
  
#  def initialize( attrs={} )
#    super
#  end
  
  def create_or_update_datastream ds_name, file
    case file
    when File
        logger.debug "adding #{ds_name} file datastream"
        add_file_datastream(file, :dsid => ds_name, :label => ds_name )
    when String
        from_url(file, ds_name)
    when Hash
      if file.has_key? :blob
        from_binary(file, ds_name)
      elsif file.has_key? :file
        add_file_datastream(file[:file], :dsid => ds_name.upcase, :label => ds_name, :mimeType => mime_type(file[:file_name]))
      end
    end
  end
  
end