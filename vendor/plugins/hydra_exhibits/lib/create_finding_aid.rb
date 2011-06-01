require 'rubygems'
require 'xml/xslt'
require "#{RAILS_ROOT}/vendor/plugins/hydra_repository/lib/mediashelf/active_fedora_helper.rb"
require "#{RAILS_ROOT}/vendor/plugins/hydra_repository/app/helpers/application_helper.rb"
require 'logger'
module CreateFindingAid
class FullFindingAid < ActiveFedora::Base
  def self.build_xml(collection_pid)
    log = Logger.new('batchIngester.log')
    collection_check = Collection.find_by_fields_by_solr({"id_s"=>collection_pid})
    if(collection_check.to_a.length < 1)
      log.error("Cannot create the finding aid for collection with PID: #{collection_pid} as it not found in the repository.")
    else
      collection_obj = Collection.load_instance(collection_pid)
      c01s = collection_obj.members(:rows=>"1024")
      cc = collection_obj
      finding_aid_check = FindingAid.find_by_fields_by_solr({"finding_aid_for_s"=>collection_pid})
      if(finding_aid_check.to_a.length < 1)
        finding_aid = FindingAid.new(:namespace=>"RBSC-CURRENCY")
        finding_aid.update_indexed_attributes({:finding_aid_for=>{0=>collection_pid}})
        finding_aid.part_of_append(collection_obj.pid)
      else
        finding_aid = FindingAid.load_instance(finding_aid_check.to_a[0]["id"])
      end
    
#    ead_id 			= collection_obj.datastreams["descMetadata"].get_values([:ead_header, :eadid])
#    ead_title 			= collection_obj.datastreams["descMetadata"].get_values([:ead_header, :filedesc, :titlestmt, :titleproper])
#    ead_author 			= collection_obj.datastreams["descMetadata"].get_values([:ead_header, :filedesc, :titlestmt, :author])
#    ead_publisher 		= collection_obj.datastreams["descMetadata"].get_values([:ead_header, :filedesc, :publicationstmt, :publisher])
#    ead_address 		= collection_obj.datastreams["descMetadata"].get_values([:ead_header, :filedesc, :publicationstmt, :address, :addressline])
#    ead_date 			= collection_obj.datastreams["descMetadata"].get_values([:ead_header, :filedesc, :publicationstmt, :date])
#    ead_creation 		= collection_obj.datastreams["descMetadata"].get_values([:ead_header, :profiledesc, :creation])
#    ead_creation_date 		= collection_obj.datastreams["descMetadata"].get_values([:ead_header, :profiledesc, :creation, :date])
#    ead_langusage 		= collection_obj.datastreams["descMetadata"].get_values([:ead_header, :profiledesc, :langusage])
#    ead_language 		= collection_obj.datastreams["descMetadata"].get_values([:ead_header, :profiledesc, :langusage, :language])
#    ead_frontmatter_title 	= collection_obj.datastreams["descMetadata"].get_values([:frontmatter, :titlepage, :titleproper])
#    ead_head 			= collection_obj.datastreams["descMetadata"].get_values([:archive_desc, :did, :head])
#    ead_unittitle 		= collection_obj.datastreams["descMetadata"].get_values([:archive_desc, :did, :unittitle])
#    ead_unitid 			= collection_obj.datastreams["descMetadata"].get_values([:archive_desc, :did, :unitid])
#    ead_unitdate 		= collection_obj.datastreams["descMetadata"].get_values([:archive_desc, :did, :unitdate])
#    ead_lang_language 		= collection_obj.datastreams["descMetadata"].get_values([:archive_desc, :did, :lang, :language])
#    ead_corpname 		= collection_obj.datastreams["descMetadata"].get_values([:archive_desc, :did, :repo, :corpname])
#    ead_subarea 		= collection_obj.datastreams["descMetadata"].get_values([:archive_desc, :did, :repo, :corpname, :subarea])
#    ead_subarea_address		= collection_obj.datastreams["descMetadata"].get_values([:archive_desc, :did, :repo, :address, :addressline])
#    ead_access 			= collection_obj.datastreams["descMetadata"].get_values([:archive_desc, :accessrestrict])
#    ead_access_head 		= collection_obj.datastreams["descMetadata"].get_values([:archive_desc, :accessrestrict, :head])
#    ead_acq_info 		= collection_obj.datastreams["descMetadata"].get_values([:archive_desc, :acqinfo])
#    ead_acq_head 		= collection_obj.datastreams["descMetadata"].get_values([:archive_desc, :acqinfo, :head])
#    ead_prefercite 		= collection_obj.datastreams["descMetadata"].get_values([:archive_desc, :prefercite])
#    ead_prefercite_head 	= collection_obj.datastreams["descMetadata"].get_values([:archive_desc, :prefercite, :head])

#    cc.update_indexed_attributes({[:ead_header, :eadid]=>{"0"=>ead_id}})
#    cc.update_indexed_attributes({[:ead_header, :filedesc, :titlestmt, :titleproper]=>{"0"=>ead_title}})
#    cc.update_indexed_attributes({[:ead_header, :filedesc, :titlestmt, :author]=>{"0"=>ead_author}})
#    cc.update_indexed_attributes({[:ead_header, :filedesc, :publicationstmt, :publisher]=>{"0"=>ead_publisher}})
#    cc.update_indexed_attributes({[:ead_header, :filedesc, :publicationstmt, :address, :addressline]=>{"0"=>ead_address}})
#    cc.update_indexed_attributes({[:ead_header, :filedesc, :publicationstmt, :date]=>{"0"=>ead_date}})
#    cc.update_indexed_attributes({[:ead_header, :profiledesc, :creation]=>{"0"=>ead_creation}})
#    cc.update_indexed_attributes({[:ead_header, :profiledesc, :creation, :date]=>{"0"=>ead_creation_date}})
#    cc.update_indexed_attributes({[:ead_header, :profiledesc, :langusage]=>{"0"=>ead_langusage}})
#    cc.update_indexed_attributes({[:ead_header, :profiledesc, :langusage, :language]=>{"0"=>ead_language}})
#    cc.update_indexed_attributes({[:frontmatter, :titlepage, :titleproper]=>{"0"=>ead_frontmatter_title}})
#    cc.update_indexed_attributes({[:archive_desc, :did, :head]=>{"0"=>ead_head}})
#    cc.update_indexed_attributes({[:archive_desc, :did, :unittitle]=>{"0"=>ead_unittitle}})
#    cc.update_indexed_attributes({[:archive_desc, :did, :unitid]=>{"0"=>ead_unitid}})
#    cc.update_indexed_attributes({[:archive_desc, :did, :unitdate]=>{"0"=>ead_unitdate}})
#    cc.update_indexed_attributes({[:archive_desc, :did, :lang, :language]=>{"0"=>ead_lang_language}})
#    cc.update_indexed_attributes({[:archive_desc, :did, :repo, :corpname]=>{"0"=>ead_corpname}})
#    cc.update_indexed_attributes({[:archive_desc, :did, :repo, :corpname, :subarea]=>{"0"=>ead_subarea}})
#    cc.update_indexed_attributes({[:archive_desc, :did, :repo, :address, :addressline]=>{"0"=>ead_subarea_address}})
#    cc.update_indexed_attributes({[:archive_desc, :accessrestrict]=>{"0"=>ead_access}})
#    cc.update_indexed_attributes({[:archive_desc, :accessrestrict, :head]=>{"0"=>ead_access_head}})
#    cc.update_indexed_attributes({[:archive_desc, :acqinfo]=>{"0"=>ead_acq_info}})
#    cc.update_indexed_attributes({[:archive_desc, :acqinfo, :head]=>{"0"=>ead_acq_head}})
#    cc.update_indexed_attributes({[:archive_desc, :prefercite]=>{"0"=>ead_prefercite}})
#    cc.update_indexed_attributes({[:archive_desc, :prefercite, :head]=>{"0"=>ead_prefercite_head}})

      c01s.each_with_index do |c, counter|
        c_xml      = c.datastreams["descMetadata"].to_xml
        unitid     = c.datastreams["descMetadata"].get_values([:collection, :did, :unitid])
        unitid_id  = c.datastreams["descMetadata"].get_values([:collection, :did, :unitid, :unitid_identifier])
        printer    = c.datastreams["descMetadata"].get_values([:collection, :did, :origination, :printer])
        engraver   = c.datastreams["descMetadata"].get_values([:collection, :did, :origination, :engraver])
        unitdate   = c.datastreams["descMetadata"].get_values([:collection, :did, :unittitle, :unitdate])
        geography  = c.datastreams["descMetadata"].get_values([:collection, :did, :unittitle, :imprint, :geogname])
        publisher  = c.datastreams["descMetadata"].get_values([:collection, :did, :unittitle, :imprint, :publisher])
        unittitle  = c.datastreams["descMetadata"].get_values([:collection, :did, :unittitle, :unittitle_content])
        desc       = c.datastreams["descMetadata"].get_values([:collection, :scopecontent])
        display    = c.datastreams["descMetadata"].get_values([:collection, :odd])
        genreform  = c.datastreams["descMetadata"].get_values([:collection, :controlaccess, :genreform])
        cc.insert_new_node('subcollection', c_xml)
        cc.update_indexed_attributes({[:archive_desc, :dsc, {:collection => (counter+1)}, :did, :unitid]=>{"0"=>unitid}})
        cc.update_indexed_attributes({[:archive_desc, :dsc, {:collection => (counter+1)}, :did, :unitid, :unitid_identifier]=>{"0"=>(unitid_id.nil? ? "" : (unitid_id.first.nil? ? "" : unitid_id.first))}})
        cc.update_indexed_attributes({[:archive_desc, :dsc, {:collection => (counter+1)}, :did, :origination, :printer]=>{"0"=>printer}})
        cc.update_indexed_attributes({[:archive_desc, :dsc, {:collection => (counter+1)}, :did, :origination, :engraver]=>{"0"=>engraver}})
        cc.update_indexed_attributes({[:archive_desc, :dsc, {:collection => (counter+1)}, :did, :unittitle, :unitdate]=>{"0"=>unitdate}}) #new stuff
        cc.update_indexed_attributes({[:archive_desc, :dsc, {:collection => (counter+1)}, :did, :unittitle, :imprint, :geogname]=>{"0"=>geography}})
        cc.update_indexed_attributes({[:archive_desc, :dsc, {:collection => (counter+1)}, :did, :unittitle, :imprint, :publisher]=>{"0"=>publisher}})
        cc.update_indexed_attributes({[:archive_desc, :dsc, {:collection => (counter+1)}, :did, :unittitle, :unittitle_content]=>{"0"=>unittitle}}) #new stuff
        cc.update_indexed_attributes({[:archive_desc, :dsc, {:collection => (counter+1)}, :scopecontent]=>{"0"=>desc}})#utf_desc
        cc.update_indexed_attributes({[:archive_desc, :dsc, {:collection => (counter+1)}, :odd]=>{"0"=>display}})
        cc.update_indexed_attributes({[:archive_desc, :dsc, {:collection => (counter+1)}, :controlaccess, :genreform]=>{"0"=>genreform}})
        c02s = c.members(:rows=>"1024")
        c02s.each_with_index do |c2, counter2|
	  c2_id		= c2.datastreams["descMetadata"].get_values([:item, :did, :unitid])
          c2_disp_signer	= c2.datastreams["descMetadata"].get_values([:item, :did, :origination, :persname, :persname_normal])
          c2_signer	= c2.datastreams["descMetadata"].get_values([:item, :did, :origination, :persname])
          c2_title	= c2.datastreams["descMetadata"].get_values([:item, :did, :unittitle])
          c2_disp_title	= c2.datastreams["descMetadata"].get_values([:item, :did, :unittitle, :unittitle_label])
          c2_num		= c2.datastreams["descMetadata"].get_values([:item, :did, :unittitle, :num])
          c2_physdesc	= c2.datastreams["descMetadata"].get_values([:item, :did, :physdesc, :dimensions])
          c2_desc		= c2.datastreams["descMetadata"].get_values([:item, :scopecontent])
          c2_genreform	= c2.datastreams["descMetadata"].get_values([:item, :controlaccess, :genreform])
          c2_plateletter	= c2.datastreams["descMetadata"].get_values([:item, :odd])
          c2_provenance	= c2.datastreams["descMetadata"].get_values([:item, :acqinfo])
          c2_images	= c2.datastreams["descMetadata"].get_values([:item, :daogrp, :daoloc, :daoloc_href])
	  cc.insert_new_node('item', opts={})
  	  cc.update_indexed_attributes({[:archive_desc, :dsc, {:collection => (counter+1)}, {:item => (counter2+1)}, :did, :unitid]=>{"0"=>c2_id}})
          cc.update_indexed_attributes({[:archive_desc, :dsc, {:collection => (counter+1)}, {:item => (counter2+1)}, :did, :origination, :persname, :persname_normal]=>{"0"=>(c2_disp_signer.nil? ? "" : (c2_disp_signer.first.nil? ? "" : c2_disp_signer.first))}})
          cc.update_indexed_attributes({[:archive_desc, :dsc, {:collection => (counter+1)}, {:item => (counter2+1)}, :did, :origination, :persname]=>{"0"=>c2_signer}})
          cc.update_indexed_attributes({[:archive_desc, :dsc, {:collection => (counter+1)}, {:item => (counter2+1)}, :did, :unittitle]=>{"0"=>c2_title}})
          cc.update_indexed_attributes({[:archive_desc, :dsc, {:collection => (counter+1)}, {:item => (counter2+1)}, :did, :unittitle, :unittitle_label]=>{"0"=>c2_disp_title.first}})
          cc.update_indexed_attributes({[:archive_desc, :dsc, {:collection => (counter+1)}, {:item => (counter2+1)}, :did, :unittitle, :num]=>{"0"=>c2_num}})
          cc.update_indexed_attributes({[:archive_desc, :dsc, {:collection => (counter+1)}, {:item => (counter2+1)}, :did, :physdesc, :dimensions]=>{"0"=>c2_physdesc}})
          cc.update_indexed_attributes({[:archive_desc, :dsc, {:collection => (counter+1)}, {:item => (counter2+1)}, :scopecontent]=>{"0"=>c2_desc}})#utf_desc
          cc.update_indexed_attributes({[:archive_desc, :dsc, {:collection => (counter+1)}, {:item => (counter2+1)}, :controlaccess, :genreform]=>{"0"=>c2_genreform}})
          cc.update_indexed_attributes({[:archive_desc, :dsc, {:collection => (counter+1)}, {:item => (counter2+1)}, :odd]=>{"0"=>c2_plateletter}})
          cc.update_indexed_attributes({[:archive_desc, :dsc, {:collection => (counter+1)}, {:item => (counter2+1)}, :acqinfo]=>{"0"=>c2_provenance}})
	  c2_images.each_with_index do |img, cnter|
	    if(cnter > 0)
              cc.insert_new_node('col_image', opts={})
            end
            cc.update_indexed_attributes({[:archive_desc, :dsc, {:collection => (counter+1)}, {:item => (counter2+1)}, :daogrp, {:daoloc=>cnter}, :daoloc_href]=>{"0"=>img}})
	  end
        end
      end
      xml_string = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
      xml_string += cc.datastreams["descMetadata"].to_xml
      patrn1 = "<c01 level=\"item\"/>"
      patrn2 = "<c02/>"
      log.info("Patrn1? #{xml_string.include? patrn1}")
      while (xml_string.include? patrn1) do
        xml_string = xml_string.sub(patrn1,"")
      end
      log.info("Patrn1? #{xml_string.include? patrn1}")
      log.info("Patrn2? #{xml_string.include? patrn2}")
      while (xml_string.include? patrn2) do
        xml_string = xml_string.sub(patrn2,"")
      end
      log.info("Patrn2? #{xml_string.include? patrn2}")
      xml_string = xml_string.sub("xmlns=\"currency-collection\"","")
      fname = "#{RAILS_ROOT}/vendor/plugins/hydra_exhibits/app/views/finding_aid/finding_aid.xml"
      xml_file = File.open(fname,"w")
      xml_string = xml_string.sub("<?xml version=\"1.0\"?>", "")
      xml_file.puts xml_string
      xml_file.close
      xsl_transform(xml_string)
      finding_aid.add_file_datastream(File.open(fname,"r"), {:label => "EAD", :dsid => "EAD"})
      finding_aid.datastreams["rightsMetadata"].update_permissions({"group"=>{"archivist"=>"edit","public"=>"read"}})
      finding_aid.save
    end
  end
  def self.xsl_transform(xml_string)
    xslt = XML::XSLT.new()
    xslt.xml = xml_string
    xslt.xsl = "#{RAILS_ROOT}/vendor/plugins/hydra_exhibits/collection.xsl"
    fname = "#{RAILS_ROOT}/vendor/plugins/hydra_exhibits/app/views/finding_aid/_collection.html"
    file = File.open(fname,"w")
    file.puts xslt.serve()
    file.close
  end
end
end
