# You can configure Blacklight from here. 
#   
#   Blacklight.configure(:environment) do |config| end
#   
# :shared (or leave it blank) is used by all environments. 
# You can override a shared key by using that key in a particular
# environment's configuration.
# 
# If you have no configuration beyond :shared for an environment, you
# do not need to call configure() for that environment.
# 
# For specific environments:
# 
#   Blacklight.configure(:test) {}
#   Blacklight.configure(:development) {}
#   Blacklight.configure(:production) {}
# 

Blacklight.configure(:shared) do |config|
  
  # default params for the SolrDocument.search method
  SolrDocument.default_params[:search] = {
    :qt=>:search,
    :per_page => 10,
    :facets => {:fields=>
      ["date_t",
        "title_t",
        "medium_t",
        "location_t"]
    }  
  }
  
  # default params for the SolrDocument.find_by_id method
  SolrDocument.default_params[:find_by_id] = {
    :qt => :document,
    :facets => {:fields=>
      ["date_t",
        "title_t",
        "medium_t",
        "location_t"]
      }
    }
  
  
  ##############################
  
  
  config[:default_qt] = "search"
  config[:public_qt] = "public_search"
  

  # solr field values given special treatment in the show (single result) view
  config[:show] = {
    :html_title => "title_t",
    :heading => "title_t",
    :display_type => "has_model_s"
  }

  # solr fld values given special treatment in the index (search results) view
  config[:index] = {
    :show_link => "title_facet",
    :num_per_page => 10,
    :record_display_type => "id"
  }

  # solr fields that will be treated as facets by the blacklight application
  #   The ordering of the field names is the order of the display 
  config[:facet] = {
    :field_names => [
      "collection_0_did_0_unittitle_0_imprint_0_publisher_facet",
      "collection_0_did_0_unittitle_0_unittitle_content_facet",
      "collection_0_did_0_unittitle_0_imprint_0_geogname_facet",
      "collection_0_did_0_origination_0_printer_facet",
      "collection_0_did_0_origination_0_engraver_facet",
      "item_0_did_0_physdesc_0_dimensions_facet",
      "item_0_acqinfo_facet",
      "item_0_did_0_origination_0_persname_0_persname_normal_facet",
      "active_fedora_model_s"
      ],
    :labels => {
      "collection_0_did_0_unittitle_0_imprint_0_publisher_facet"=>"Publisher",
      "collection_0_did_0_unittitle_0_unittitle_content_facet"=>"Print Date",
      "collection_0_did_0_unittitle_0_imprint_0_geogname_facet"=>"Printing Location",
      "collection_0_did_0_origination_0_printer_facet"=>"Printer",
      "collection_0_did_0_origination_0_engraver_facet"=>"Engraver",
      "item_0_did_0_origination_0_persname_0_persname_normal_facet"=>"Signers"
      "active_fedora_model_s" => "Description"
    },
    :limits=> {nil=>10}
  }

  # solr fields to be displayed in the index (search results) view
  #   The ordering of the field names is the order of the display 
  config[:index_fields] = {
    :field_names => [
      "date_t",
      "title_t",
      "medium_t",
      "location_t",
      "collection_did_unitid_t",      
      "collection_did_unittitle_unittitle_content_t",
      "collection_did_unittitle_imprint_publisher_t",
      "collection_controlaccess_genreform_t",
      "ead_ead_header_filedesc_titlestmt_titleproper_t"
      ],
    :labels => {
      "date_t"=>"Date",
      "title_t"=>"Title",
      "medium_t"=>"Content Type",
      "location_t"=>"Location",      
      "collection_did_unitid_t"                      => "ID",
      "collection_did_unittitle_unittitle_content_t" => "Print Date",
      "collection_did_unittitle_imprint_publisher_t" => "Publisher",
      "collection_controlaccess_genreform_t"         => "Genre",
      "ead_ead_header_filedesc_titlestmt_titleproper_t" => "Parent Collection"
    }
  }

  config[:collections_index_fields] = {
    :field_names => [        
        "ead_ead_header_filedesc_titlestmt_titleproper_t",
        "ead_archive_desc_did_lang_t",
        "ead_archive_desc_did_unitdate_t",
        "ead_header_filedesc_titlestmt_author_t",
        "did_ref_0_head_t",
        "did_ref_unittitle_t"
      ],
    :labels => {
      "ead_ead_header_filedesc_titlestmt_titleproper_t" =>"Title",
      "ead_archive_desc_did_lang_t"                     => "Language",
      "ead_archive_desc_did_unitdate_t"                 => "Date",
      "ead_header_filedesc_titlestmt_author_t"          => "Author",
      "did_ref_0_head_t"                                => "Heading",
      "did_ref_unittitle_t"                             => "Genre"
    }
  }

  config[:items_index_fields] = {
    :field_names => [
      "item_did_unittitle_unittitle_content_t",
      "item_did_unitid_t",
      "collection_0_did_0_origination_0_engraver_t",
      "item_0_did_0_origination_0_persname_0_persname_normal_t",
      "item_did_physdesc_dimensions_t",
      "item_ref_0_acqinfo_t",
      "collection_did_unittitle_imprint_publisher_t",
      "collection_did_unittitle_unittitle_content_t",
      "ead_ead_header_filedesc_titlestmt_titleproper_t"
      ],
    :labels => {
      "item_did_unittitle_unittitle_content_t"                  => "Title",
      "item_did_unitid_t"                                       => "ID",
      "collection_0_did_0_origination_0_engraver_t"       => "Engraver",
      "item_0_did_0_origination_0_persname_0_persname_normal_t" => "Signers" ,
      "item_did_physdesc_dimensions_t"                          => "Physical Dimensions",
      "item_ref_0_acqinfo_t"                                    => "Provenance",
      "collection_did_unittitle_imprint_publisher_t"        => "Publisher",
      "collection_did_unittitle_unittitle_content_t"        => "Print Date",
      "ead_ead_header_filedesc_titlestmt_titleproper_t"         => "Parent Collection"
    }
  }

  config[:pages_index_fields] = {
    :field_names => [
      "title_t",
      "name_t",
      "page_id_t",
      "collection_did_unittitle_unittitle_content_t",
      "collection_did_unittitle_imprint_publisher_t",
      "ead_ead_header_filedesc_titlestmt_titleproper_t"
      ],
    :labels => {
      "title_t"    						=> "Title",
      "name_t"     						=> "Name",
      "page_id_t"       					=> "ID",
      "collection_did_unittitle_unittitle_content_t"	=> "Date",
      "collection_did_unittitle_imprint_publisher_t"	=> "Publisher",
      "ead_ead_header_filedesc_titlestmt_titleproper_t"		=> "Parent Collection"
    }
  }

  # solr fields to be displayed in the show (single result) view
  #   The ordering of the field names is the order of the display 
  config[:show_fields] = {
    :field_names => [
      "text",
      "title_facet",
      "date_t",
      "medium_t",
      "location_t",
      "collection_did_unitid_unitid_identifier_t",
      "collection_did_unittitle_unittitle_content_t",
      "collection_did_unittitle_imprint_publisher_t",
      "collection_controlaccess_genreform_t",
      "collection_scopecontent_t",
      "item_did_unittitle_unittitle_content_t",
      "item_did_unittitle_t",
      "item_did_unitid_t",
      "item_did_unittitle_num_t",
      "item_did_origination_signer_persname_normal_t",
      "item_did_origination_signer_t",
      "item_did_physdesc_dimensions_t",
      "item_controlaccess_genreform_t",
      "item_acqinfo_t",
      "item_odd_t",
      "item_daogrp_daoloc_daoloc_href_t",
      "rights_t",
      "access_t"
    ],
    :labels => {
      "text" => "Text:",
      "title_facet" => "Title:",
      "date_t" => "Date:",
      "medium_t" => "Document Type:",
      "location_t" => "Location:",
      "collection_did_unitid_t"                      => "Unique ID",
      "collection_did_unitid_unitid_identifier_t"    => "ID",
      "collection_did_unittitle_unittitle_content_t" => "Emission Date",
      "collection_did_unittitle_imprint_publisher_t" => "Publisher",
      "collection_controlaccess_genreform_t"         => "Genre",
      "collection_scopecontent_t"                    => "Content",
      "item_did_unittitle_unittitle_content_t"           => "Display Title",
      "item_did_unittitle_t"                             => "Title",
      "item_did_unitid_t"                                => "ID",
      "item_did_unittitle_num_t"                         => "Serial Number",
      "item_did_origination_signer_persname_normal_t"    => "Display Signers",
      "item_did_origination_signer_t"                    => "Signers",
      "item_did_physdesc_dimensions_t"                   => "Physical Description",
      "item_controlaccess_genreform_t"                   => "Page Turn",
      "item_acqinfo_t"                                   => "Provenance",
      "item_odd_t"                                       => "Plate Letter",
      "item_daogrp_daoloc_daoloc_href_t"                 => "Images",
      "rights_t"  => "Copyright:",
      "access_t" => "Access:"
    }
  }

# FIXME: is this now redundant with above?
  # type of raw data in index.  Currently marcxml and marc21 are supported.
  config[:raw_storage_type] = "marc21"
  # name of solr field containing raw data
  config[:raw_storage_field] = "marc_display"

  # "fielded" search select (pulldown)
  # label in pulldown is followed by the name of a SOLR request handler as 
  # defined in solr/conf/solrconfig.xml
  config[:search_fields] ||= []
  config[:search_fields] << ['Descriptions', 'search']
  config[:search_fields] << ['Descriptions and full text', 'fulltext']
  
  # "sort results by" select (pulldown)
  # label in pulldown is followed by the name of the SOLR field to sort by and
  # whether the sort is ascending or descending (it must be asc or desc
  # except in the relevancy case).
  # label is key, solr field is value
  config[:sort_fields] ||= []
  config[:sort_fields] << ['relevance', 'score desc, year_facet desc, month_facet asc, title_facet asc']
  config[:sort_fields] << ['date -', 'year_facet desc, month_facet asc, title_facet asc']
  config[:sort_fields] << ['date +', 'year_facet asc, month_facet asc, title_facet asc']
  config[:sort_fields] << ['title', 'title_facet asc']
  config[:sort_fields] << ['document type', 'medium_t asc, year_facet desc, month_facet asc, title_facet asc']
  config[:sort_fields] << ['location', 'series_facet asc, box_facet asc, folder_facet asc, year_facet desc, month_facet asc, title_facet asc']
  
  # If there are more than this many search results, no spelling ("did you 
  # mean") suggestion is offered.
  config[:spell_max] = 5
  
  # number of facets to show before adding a more link
  config[:facet_more_num] = 5
end
