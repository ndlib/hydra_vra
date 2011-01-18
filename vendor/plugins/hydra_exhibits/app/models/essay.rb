require "hydra"

class Essay < ActiveFedora::Base

  include Hydra::ModelMethods
  
  has_bidirectional_relationship  "description_of", :is_description_of, :has_description

  has_metadata   :name => "rightsMetadata",                 :type =>Hydra::RightsMetadata
  has_metadata   :name => "descMetadata",                   :type =>ActiveFedora::QualifiedDublinCoreDatastream do |m|
    m.field "title", :string, :xml_node => "title"
  end

  has_datastream :name=>"essaydatastream", :type=>ActiveFedora::Datastream, :mimeType=>"text/html", :controlGroup=>'M'

  def label=(label)
    super
    datastreams_in_memory["descMetadata"].title_values = label
  end

  def content
    essaydatastream.first.content unless essaydatastream.nil? || essaydatastream.empty?
  end

  def title
    return @essay_title if (defined? @essay_title)
    values = self.fields[:title][:values]
    @essay_title = values.any? ? values.first : ""
  end

end
