require 'hydra'

class Page < ActiveFedora::Base
  include Hydra::GenericImage
  include Hydra::ModelMethods
  
  has_bidirectional_relationship  "item",   :is_part_of, :has_part
  has_bidirectional_relationship  "descriptions", :is_description_of, :has_description
  
  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 

  has_metadata :name => "descMetadata", :type => ActiveFedora::QualifiedDublinCoreDatastream
  
  # A place to put extra metadata values
  has_metadata :name => "properties", :type => ActiveFedora::MetadataDatastream do |m|
    m.field 'collection', :string
    m.field 'depositor', :string
    m.field 'title', :string
    m.field 'name', :string
    m.field 'page_id', :string
    m.field 'review', :string
    m.field 'review_comments', :string
  end

  def page_id
    return @page_id if (defined? @page_id)
    values = self.fields[:page_id][:values]
    @page_id = values.any? ? values.first : ""
  end  

  def name
    return @name if (defined? @name)
    values = self.fields[:name][:values]
    @name = values.any? ? values.first : ""
  end

  def title
    return @title if (defined? @title)
    values = self.fields[:title][:values]
    @title = values.any? ? values.first : ""
  end
 
  def self.title_solr_field_name
    ActiveFedora::SolrService.solr_name("title",:string)
  end

#  def create_or_update_datastream ds_name, file
#    case file
#    when File
#        logger.debug "adding #{ds_name} file datastream"
#        add_file_datastream(file, :dsid => ds_name, :label => ds_name )
#    when String
#        from_url(file, ds_name)
#    when Hash
#      if file.has_key? :blob
#        from_binary(file, ds_name)
#      elsif file.has_key? :file
#        add_file_datastream(file[:file], :dsid => ds_name, :label => ds_name, :mimeType => mime_type(file[:file_name]))
#      end
#    end
#  end
  def datastream_url ds_name="content"
    "#{Fedora::Repository.instance.base_url}/get/#{pid}/#{ds_name}"
  end

  #Calls to solr on the descMetadata datastream locally and any parents
  #Used by child only when indexing its parents content
  def to_solr_desc_metadata(solr_doc = Solr::Document.new)
    solr_doc = datastreams["descMetadata"].to_solr(solr_doc)
    solr_doc = to_solr_parent_desc_metadata(solr_doc)
    return solr_doc
  end

  #Calls to_solr on the descMetadata datastream of parent
  def to_solr_parent_desc_metadata(solr_doc = Solr::Document.new)
    item.each do |parent|
      if parent.respond_to? :to_solr_desc_metadata
        solr_doc = parent.to_solr_desc_metadata(solr_doc) 
        logger.debug("Solrized parent #{parent.pid} desc metadata in child #{pid}")
      end
    end
    return solr_doc
  end

  #Index all of parent ead content in the child
  def to_solr(solr_doc = Solr::Document.new, opts={})
    doc = super(solr_doc, opts)
    doc = to_solr_parent_desc_metadata(doc)
    return doc
  end
end
