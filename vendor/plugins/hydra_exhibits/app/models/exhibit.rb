require "hydra"

#Currency
class Exhibit < ActiveFedora::Base
  
  include Hydra::ModelMethods

  has_bidirectional_relationship "members", :has_member, :is_member_of
  #reusing parts here because has_subset taken already
  has_bidirectional_relationship "featured", :has_part, :is_part_of
  has_bidirectional_relationship "subsets", :has_subset, :is_subset_of
  has_bidirectional_relationship  "descriptions",   :has_description, :is_description_of
  has_relationship "collections", :has_constituent
    
  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 

  # Uses the Hydra MODS Article profile for tracking most of the descriptive metadata
  has_metadata :name => "descMetadata", :type => ActiveFedora::MetadataDatastream do |m|
    #m.field "main_description", :string, :xml_node => "main_description"
    m.field "exhibit_title", :string, :xml_node => "exhibit_title"
  end

  # A datastream to hold browseable facet list
  has_metadata :name => "filters", :type => ActiveFedora::MetadataDatastream do |m|
    m.field "facets", :string
    m.field "query", :string
    m.field "tags", :string
  end

  def title
   return @exhibit_title if (defined? @exhibit_title)
    values = self.fields[:exhibit_title][:values]
    @exhibit_title = values.any? ? values.first : "unnamed exhibit"
  end

  def exhibit_title
   return @exhibit_title if (defined? @exhibit_title)
    values = self.fields[:exhibit_title][:values]
    @exhibit_title = values.any? ? values.first : ""
  end

  def build_members_query
    q = ""
    field_queries = []
    unless query_values.empty?
      query_values.each do |query_value|
        field_queries << "_query_:\"#{query_value}\""
      end
    end
    q << "#{field_queries.join(" AND ")}"
  end

  def query_values
    #["id_t:RBSC-CURRENCY"]
    #["id_t:RBSC-CURRENCY","collection_0_did_0_unittitle_0_imprint_0_publisher_facet:Connecticut"]
    datastreams["filters"].query_values
  end

  def load_facet_subsets_map
    @facet_subsets_map = {}
    subsets.each do |subset|
      if subset.respond_to? :selected_facets
        @facet_subsets_map.merge!({subset.selected_facets=>subset})
      end
    end
    @facet_subsets_map
  end

  def facet_subsets_map
    load_facet_subsets_map if @facet_subsets_map.nil? || @relationships_are_dirty || rels_ext.relationships_are_dirty
    @facet_subsets_map
  end

  def browse_facets
    datastreams["filters"].fields[:facets][:values]
  end
  
  def insert_new_node(type, opts)
    ds = self.datastreams_in_memory["descMetadata"]
    node, index = ds.insert_node(type, opts)
    return node, index
  end

  def description_list
    descriptions.any? ? descriptions : nil
  end
  
  def remove_image(type, index)
    ds = self.datastreams_in_memory["descMetadata"]
    result = ds.remove_node(type,index)
    return result
  end

=begin
  def title
    return @exhibit_description_title if (defined? @exhibit_description_title)
    values = self.fields[:main_description][:values]
    @exhibit_description_title = values.any? ? values.first : ""
  end
=end

end
