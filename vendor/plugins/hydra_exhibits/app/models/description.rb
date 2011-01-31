require "hydra"

class Description < ActiveFedora::Base

  include Hydra::ModelMethods
  
  has_bidirectional_relationship  "description_of", :is_description_of, :has_description

  has_metadata   :name => "rightsMetadata",                 :type =>Hydra::RightsMetadata
  has_metadata   :name => "descMetadata",                   :type =>ActiveFedora::MetadataDatastream do |m|
    m.field "title", :string, :xml_node => "title"
    m.field "page_display", :string, :xml_node => "page_display"
    m.field "summary", :string, :xml_node => "summary"
  end

  has_datastream :name=>"descriptiondatastream", :type=>ActiveFedora::Datastream, :mimeType=>"text/html", :controlGroup=>'M'

  def label=(label)
    super
    datastreams_in_memory["descMetadata"].title_values = label
  end

  def content
    descriptiondatastream.first.content unless descriptiondatastream.nil? || descriptiondatastream.empty?
  end

  def title
    return @description_title if (defined? @description_title)
    values = self.fields[:title][:values]
    @description_title = values.any? ? values.first : ""
  end

  def summary
    return @summary if (defined? @summary)
    values = self.fields[:summary][:values]
    @summary = values.any? ? values.first : ""
  end

  def style
    return @style if (defined? @style)
    values = self.fields[:page_display][:values]
    @style = values.any? ? values.first : "newpage"
  end

end
