require 'hydra'
require 'facets/dictionary'
#Currency
class Component < ActiveFedora::Base

  include Hydra::ModelMethods
  include ComponentsControllerHelper

  has_bidirectional_relationship "member_of", :is_member_of, :has_member
  has_bidirectional_relationship "members", :has_member, :is_member_of
  has_bidirectional_relationship "page", :has_part_of, :is_part_of
  has_bidirectional_relationship "featured_of", :is_part_of, :has_part

  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 

  # Uses the Hydra MODS Article profile for tracking most of the descriptive metadata
  has_metadata :name => "descMetadata", :type => EadXml

  # A place to put extra metadata values
  has_metadata :name => "properties", :type => ActiveFedora::MetadataDatastream do |m|
    m.field 'collection', :string
    m.field 'depositor', :string
    m.field "subcollection_id", :string
    m.field "item_id", :string
    m.field "main_page", :string
    m.field "main_item", :string
    m.field "component_type", :string
    m.field 'review', :string
    m.field 'review_comments', :string
    m.field 'date', :string
  end

  alias_method :id, :pid

  def component_type
    return @component_type if (defined? @component_type)
    values = self.fields[:component_type][:values]
    @component_type = values.any? ? values.first : ""
  end

  def subcollection_id
    return @subcollection_id if (defined? @subcollection_id)
    values = self.fields[:subcollection_id][:values]
    @subcollection_id = values.any? ? values.first : ""
  end

  def item_id
    return @item_id if (defined? @item_id)
    values = self.fields[:item_id][:values]
    @item_id = values.any? ? values.first : ""
  end

  def main_page
    return @main_page if (defined? @main_page)
    values = self.fields[:main_page][:values]
    @main_page = values.any? ? values.first : ""
  end

  def main_item
    return @main_item if (defined? @main_item)
    values = self.fields[:main_item][:values]
    @main_item = values.any? ? values.first : ""
  end

  def insert_new_node(type, opts)
    ds = self.datastreams_in_memory["descMetadata"]
    node, index = ds.insert_node(type, opts)
    return node, index
  end

  def remove_image(type, index)
    ds = self.datastreams_in_memory["descMetadata"]
    result = ds.remove_node(type,index)
    return result
  end

#  def get_component_level
#    return @component_level
#  end

  def type
    @type ||= get_type_from_datastream
  end

  def list_childern(item_id, type)
    #@asset = Component.load_instance_from_solr(item_id)
    arr = Array.new
    if(type.eql?"item")
      childern = page #inbound_relationships[:is_part_of]
      if(!(childern.nil?) && childern.size > 0)
        childern.each { |child|
          arr.push(child)
        }
      end
    else #if(type.eql?"subcollection")
      ids = members_ids
      ids.each { |id|
	child_obj = Component.load_instance_from_solr(id)
        arr.push(child_obj)
      }
    end
    return arr
  end

  def get_type_from_datastream
    if self.has_value_for("descMetadata", [:item])
      :item
    elsif self.has_value_for("descMetadata", [:collection])
      :collection
    else
      :unknown
    end
  end

  def metadata_fields
    field_keys[:descMetadata][type] rescue nil
  end

  def self.title_solr_field_name(co_type=type)
    (!co_type.nil? && co_type.eql?("item")) ? term_pointer = [:item, :did, :unittitle, :unittitle_content] : term_pointer = [:collection, :did, :unittitle, :unittitle_content] 
    field_name_base = OM::XML::Terminology.term_generic_name(*term_pointer)
    ActiveFedora::SolrService.solr_name(field_name_base,:string)
  end

  def item_title
    return @item_title if (defined? @item_title)
    values = self.datastreams["descMetadata"].term_values(:item, :did, :unittitle, :unittitle_content)
    @item_title = values.any? ? values.first : ""
  end

  def sub_collection_title
    return @sub_collection_title if (defined? @sub_collection_title)
    values = self.datastreams["descMetadata"].term_values(:collection, :did, :unittitle, :unittitle_content)
    @sub_collection_title = values.any? ? values.first : ""
  end

  def formatted_title
    self.item_id.blank? ? title = sub_collection_title : title = item_title
  end

  # Used this method to display parent's title as the link in the catalog view of C02 level
  def title
    return @title if (defined? @title)
    if((self.type.to_s.eql? "collection") && !(self.datastreams["descMetadata"].term_values(:collection, :did, :unittitle, :unittitle_content).empty?))  
      values = self.datastreams["descMetadata"].term_values(:collection, :did, :unittitle, :unittitle_content)
    else
      values = self.datastreams["descMetadata"].term_values(:item, :did, :unittitle, :unittitle_content)
    end
    logger.debug(@title)
    @title = values.any? ? values.first : ""
  end

  def field_keys
    {
      :descMetadata => {
        :item => Dictionary[
          "Display Title",        [:item, :did, :unittitle, :unittitle_label],
          "Title",                [:item, :did, :unittitle],
          "ID",                   [:item, :did, :unitid],
          "Serial Number",        [:item, :did, :unittitle, :num],
          "Display Signers",      [:item, :did, :origination, :signer, :persname_normal],
          "Signers",              [:item, :did, :origination, :signer],
          "Physical Description", [:item, :did, :physdesc, :dimensions], 
          "Page Turn",            [:item, :controlaccess, :genreform], 
          "Provenance",           [:item, :acqinfo],
          "Plate Letter",         [:item, :odd],
          "Images",               [:item, :daogrp, :daoloc, :daoloc_href]
        ],
        :collection => Dictionary[
          "Ead ID",                    [:ead_header, :eadid],
          "Title",                     [:ead_header, :filedesc, :titlestmt, :titleproper],
          "Author",                    [:ead_header, :filedesc, :titlestmt, :author],
          "Publisher",                 [:ead_header, :filedesc, :publicationstmt, :publisher],
          "Publisher Address",         [:ead_header, :filedesc, :publicationstmt, :address, :addressline],
          "Publisher Date",            [:ead_header, :filedesc, :publicationstmt, :date],
          "Finding Aid Creator",       [:ead_header, :profiledesc, :creation],
          "Finding Aid Creation Date", [:ead_header, :profiledesc, :creation, :date],
          "Langusage",                 [:ead_header, :profiledesc, :langusage],
          "Language",                  [:ead_header, :profiledesc, :langusage, :language],
          "Unit Head",                 [:archive_desc, :did, :head],
          "Unit Titile",               [:archive_desc, :did, :unittitle],
          "Unit Id",                   [:archive_desc, :did, :unitid],
          "Unit Date",                 [:archive_desc, :did, :unitdate],
          "Organization",              [:archive_desc, :did, :repo, :corpname],
          "Department",                [:archive_desc, :did, :repo, :corpname, :subarea],
          "Organization Address",      [:archive_desc, :did, :repo, :address, :addressline],
          "Access Restriction Info",   [:archive_desc, :accessrestrict],
          "Access Restriction Head",   [:archive_desc, :accessrestrict, :head],
          "Acquisition Info",          [:archive_desc, :acqinfo],
          "Acquisition Head",          [:archive_desc, :acqinfo, :head],
          "Prefercite Info",           [:archive_desc, :prefercite],
          "Prefercite Head",           [:archive_desc, :prefercite, :head],
          "Unique ID",                 [:collection, :did, :unitid],
          "ID",                        [:collection, :did, :unitid, :unitid, :identifier],
          "Emission Date",             [:collection, :did, :unittitle, :unittitle, :content],
          "Publisher",                 [:collection, :did, :unittitle, :imprint, :publisher],
          "Genre",                     [:collection, :controlaccess, :genreform]
        ]
      }
    }
  end

  def has_value_for(datastream, path=[])
    begin
      !self.datastreams[datastream].get_values(path).first.blank?
    rescue OM::XML::Terminology::BadPointerError
      false
    end
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
    member_of.each do |parent|
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
