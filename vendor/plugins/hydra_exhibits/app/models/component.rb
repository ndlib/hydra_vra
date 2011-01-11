require 'hydra'
require 'facets/dictionary'
#Currency
class Component < ActiveFedora::Base

  include Hydra::ModelMethods

  has_bidirectional_relationship "member_of", :is_member_of, :has_member
  has_bidirectional_relationship "members", :has_member, :is_member_of
  has_bidirectional_relationship "highlighted", :has_subset, :is_subset_of
  has_bidirectional_relationship "descriptions", :has_description, :is_description_of
  #just use parts relationship instead?
  has_bidirectional_relationship "page", :has_part_of, :is_part_of

  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 

  # Uses the Hydra MODS Article profile for tracking most of the descriptive metadata
  has_metadata :name => "descMetadata", :type => EadXml

  # A place to put extra metadata values
  has_metadata :name => "properties", :type => ActiveFedora::MetadataDatastream do |m|
    m.field "subcollection_id", :string
    m.field "item_id", :string
    m.field "component_type", :string
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

  def insert_new_node(type, opts)
    ds = self.datastreams_in_memory["descMetadata"]
    node, index = ds.insert_node(type, opts)
    return node, index
  end

  def get_component_level
    return @component_level
  end

  def type
    @type ||= get_type_from_datastream
  end

  def get_type_from_datastream
    if self.has_value_for("descMetadata", [:dsc, :collection])
      :collection
    elsif self.has_value_for("descMetadata", [:item])
      :item
    else
      :unknown
    end
  end

  def metadata_fields
    field_keys[:descMetadata][type] rescue nil
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
          "Unique ID",                 [:dsc, :collection, :did, :unitid],
          "ID",                        [:dsc, :collection, :did, :unitid, :unitid, :identifier],
          "Emission Date",             [:dsc, :collection, :did, :unittitle, :unittitle, :content],
          "Publisher",                 [:dsc, :collection, :did, :unittitle, :imprint, :publisher],
          "Genre",                     [:dsc, :collection, :controlaccess, :genreform]
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
end
