require "hydra"

#Currency
class Collection < ActiveFedora::Base
  
  include Hydra::ModelMethods

  has_bidirectional_relationship "members", :has_member, :is_member_of
  has_bidirectional_relationship "parts", :has_part, :is_part_of
  has_bidirectional_relationship  "descriptions",   :has_description, :is_description_of
    
  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 
  
  # Uses the Hydra MODS Article profile for tracking most of the descriptive metadata
  has_metadata :name => "descMetadata", :type => EadXml

  has_metadata :name => "properties", :type => ActiveFedora::MetadataDatastream do |m|
    m.field 'collection', :string
    m.field 'depositor', :string
    m.field 'last_sc_number', :string
    m.field 'last_item_number', :string
    m.field 'last_image_number', :string
    m.field 'review', :string
    m.field 'review_comments', :string
  end

  def last_sc_number
    return @last_sc_number if (defined? @last_sc_number)
    values = self.fields[:last_sc_number][:values]
    @last_sc_number = values.any? ? values.first : ""
  end

  def last_item_number
    return @last_item_number if (defined? @last_item_number)
    values = self.fields[:last_item_number][:values]
    @last_item_number = values.any? ? values.first : ""
  end

  def last_image_number
    return @last_image_number if (defined? @last_image_number)
    values = self.fields[:last_image_number][:values]
    @last_image_number = values.any? ? values.first : ""
  end

  def insert_new_node(type, opts)
    ds = self.datastreams_in_memory["descMetadata"]
    node, index = ds.insert_node(type, opts)
    return node, index
  end

#  def remove_image(type, index)
#    ds = self.datastreams_in_memory["descMetadata"]
#    result = ds.remove_node(type,index)
#    return result
#  end

  def description_list
    descriptions.any? ? descriptions : nil
  end

  def formatted_title
   return @exhibit_title if (defined? @exhibit_title)
    values = self.fields[:exhibit_title][:values]
    @exhibit_title = values.any? ? values.first : "unnamed exhibit"
  end


  def title
    return @collection_title if (defined? @collection_title)    
    values = self.datastreams["descMetadata"].term_values(:ead_header, :filedesc, :titlestmt, :titleproper)
    @collection_title = values.any? ? values.first : ""
  end

  def self.title_solr_field_name
    term_pointer = [:ead_header, :filedesc, :titlestmt, :titleproper] 
    field_name_base = OM::XML::Terminology.term_generic_name(*term_pointer)
    ActiveFedora::SolrService.solr_name(field_name_base,:string)
  end

  def list_childern(item_id, type)
    @asset = Collection.load_instance_from_solr(item_id)
    arr = Array.new
    childern = @asset.members #.inbound_relationships[:is_part_of]
    if(!(childern.nil?) && childern.size > 0)
      childern.each { |child|
        child_id = child.pid #.split('/')  
        child_obj = Component.load_instance_from_solr(child_id)
        arr.push(child_obj)
      }
    end
    return arr
  end

  #Calls to solr on the descMetadata datastream to be used by children to solrize its parent values
  #for searching only
  def to_solr_desc_metadata(solr_doc = Solr::Document.new)
    datastreams["descMetadata"].to_solr(solr_doc)
  end
  
end
