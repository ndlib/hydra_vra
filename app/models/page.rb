require "hydra"

class Page < ActiveFedora::Base
  
  include Hydra::GenericImage
  include Hydra::ModelMethods
  
  has_bidirectional_relationship  "item",   :is_part_of, :has_part, :type=>Item
#  has_relationship                "essays", :is_description_of,     :type=>Essay, :inbound=>true
  
  has_metadata   :name => "rightsMetadata",                 :type =>Hydra::RightsMetadata
  has_metadata   :name => "descMetadata",                   :type =>ActiveFedora::QualifiedDublinCoreDatastream

#  has_datastream :name=>"thumbnail",  :prefix => "THUMB",   :type=>ActiveFedora::Datastream, :mimeType=>"image/jpeg", :controlGroup=>'M'
#  has_datastream :name=>"max",        :prefix => "MAX",     :type=>ActiveFedora::Datastream, :mimeType=>"image/jpeg", :controlGroup=>'M'
#  has_datastream :name=>"screen",     :prefix => "SCREEN",  :type=>ActiveFedora::Datastream, :mimeType=>"image/jpeg", :controlGroup=>'M'
  
  def name
    return @name if (defined? @name)
    values = self.fields[:name][:values]
    @name = values.any? ? values.first : ""
  end

  def title
    name.split('-').last.gsub(/_/, ' ')
  end

  def item_name
    item.any? ? item.first.title : ""
  end

  def item_id
    item.any? ? item.first.id : ""
  end
  
  def parent_id
    item_id
  end

  def related_pages
    item.any? ? item.first.pages : []
  end 

  def has_related_pages?
    related_pages.count > 1
  end 

  def related_pages_ids
    related_pages.map{|r| r.id}
  end 
  
  def eval_view_path_string
    "catalog_path(\"#{id}\", :render_search=> 'false')"
  end

  #################################################################
  # NOTE The URL returned should probably be from a disseminator
  #################################################################
  def image(format=:screen)
    uri_param = case format
    when :thumb
      'THUMB1'
    when :screen
      'SCREEN1'
    when :max
      'MAX1'
    else
      ''
    end

    "#{FEDORA_ACCESS_URL}/get/#{pid}/#{uri_param}"
  end

  def to_solr(solr_doc = Solr::Document.new, opts={})
    doc = super(solr_doc, opts)
    doc << Solr::Field.new( :format => "page" )
    doc << Solr::Field.new( solr_name(:title, :string) => self.title)
    return doc
  end
  
  def initialize( attrs={} )
   super
  end
end
