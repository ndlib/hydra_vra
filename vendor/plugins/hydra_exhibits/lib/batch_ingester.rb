require 'rubygems'
require 'fastercsv'
require 'iconv'
require "#{RAILS_ROOT}/vendor/plugins/hydra_repository/lib/mediashelf/active_fedora_helper.rb"
require "#{RAILS_ROOT}/vendor/plugins/hydra_repository/app/helpers/application_helper.rb"
require 'logger'

module BatchIngester
  class CurrencyIngester
    include MediaShelf::ActiveFedoraHelper
    include ApplicationHelper
    def log
      log = Logger.new('batchIngester.log')
    end
#    log.level = Logger::WARN
    def process_ingest_data(filename)
      cnter = 1
      arr_of_data=load_file(filename)     
      log.info("Processing Total Rows: #{arr_of_data.length()}")
      arr_of_data.each do |row|
        if(filename.include? "Collection")
          log.info("Ingesting Subcollection Object")
          subcollection_ingest_each_row( row )
        elsif(filename.include? "Item")
          log.info("Ingesting Item Object")
          item_ingest_each_row( row, filename )
        elsif(filename.include? "Image")
          log.info("Ingesting Page Object")
          page_ingest_each_row( row, filename )
        elsif(filename.include? "Header")
          if cnter >1
            log.info("Ingesting Ead Collection Object")
            collection_ingest_each_row( row )
          end
          cnter += 1
        else
          log.info("Did not recognize Object")
        end
      end
    end

    def load_file(csv_file)
      if File.exists? (csv_file)
        arr_of_data = FasterCSV.read(csv_file, :headers=>false)
        log.info("Ingest or Remove  #{arr_of_data.length}  Objects")
        return arr_of_data
      else
        log.info("#{csv_file} does not exists!")
      end
    end
    def collection_ingest_each_row(row)
      log.info("Rows: #{row.inspect}")
      if (row[0].blank? || row[1].blank?)
        raise "This entry #{row.inspect} has empty collection information"
      else
        ead_id = row[0]
        title = row[1]
        author = row[2]
        publisher = row[3]
        address = row[4]
        date = row[5]
        creation_person = row[6]
        creation_date = row[7]
        langusage = row[8]
        language = row[9]
        unit_head = row[10]
        unit_title = row[11]
        unit_id = row[12]
        unit_date = row[13]
        unit_language = row[14]
        corp_name = row[15]
        subarea = row[16]
        unit_address = row[17]
        access_restrict_head = row[18]
        access_restrict_info = row[19]
        acquisition_head = row[20]
        acquisition_info = row[21]
        prefercite_head = row[22]
        prefercite_info = row[23]
        key = "COLLECTION_#{ead_id}"
        attributes= {:pid_key => key, :ead_id => ead_id, :title => title, :author => author, :publisher => publisher, :creator => creation_person, :creation_date => creation_date, :address => address, :date => date, :langusage => langusage, :language => language, :unit_title => unit_title, :unit_head => unit_head, :unit_id => unit_id, :unit_date => unit_date, :unit_language => unit_language, :corp_name => corp_name, :subarea => subarea, :unit_address => unit_address, :access_restrict_head => access_restrict_head, :access_restrict_info => access_restrict_info, :prefercite_head => prefercite_head, :prefercite_info => prefercite_info, :acquisition_head => acquisition_head, :acquisition_info => acquisition_info}
        ingest_collection('collection', attributes)
      end
    end
    def ingest_collection(content_type, args)
      af_model = retrieve_af_model(content_type)
      unless af_model
        af_model = Component
      end
      pid= generate_pid(args[:pid_key], nil)
      #if(!asset_available(pid,content_type))
      map = {"EAD_HEADER_0_EADID_S".downcase=>"american_colonial_currency"}
      result = Collection.find_by_fields_by_solr(map)
      log.info("Length of the search result: #{result.to_a.size}")
      if(result.to_a.size < 1)
        collection= af_model.new(:namespace=>get_namespace)#(:pid=>pid)
        collection.datastreams["descMetadata"].ng_xml = EadXml.collection_template
        collection.save
        collection.datastreams["rightsMetadata"].update_permissions({"group"=>{"archivist"=>"edit","public"=>"read"}})
        update_fields(collection, [:ead_header, :eadid], args[:ead_id])
        update_fields(collection, [:ead_header, :filedesc, :titlestmt, :titleproper], args[:title])
        update_fields(collection, [:ead_header, :filedesc, :titlestmt, :author], args[:author])
        update_fields(collection, [:ead_header, :filedesc, :publicationstmt, :publisher], args[:publisher])
        update_fields(collection, [:ead_header, :filedesc, :publicationstmt, :address, :addressline],args[:address])
        update_fields(collection, [:ead_header, :filedesc, :publicationstmt, :date], args[:date])
        update_fields(collection, [:ead_header, :profiledesc, :creation], args[:creator])
        update_fields(collection, [:ead_header, :profiledesc, :creation, :date], args[:creation_date])
        update_fields(collection, [:ead_header, :profiledesc, :langusage], args[:langusage])
        update_fields(collection, [:ead_header, :profiledesc, :langusage, :language], args[:language])
        update_fields(collection, [:frontmatter, :titlepage, :titleproper], args[:title])
        update_fields(collection, [:archive_desc, :did, :head], args[:unit_head])
        update_fields(collection, [:archive_desc, :did, :unittitle], args[:unit_title])
        update_fields(collection, [:archive_desc, :did, :unitid], args[:unit_id])
        update_fields(collection, [:archive_desc, :did, :unitdate], args[:unit_date])
        update_fields(collection, [:archive_desc, :did, :lang, :language], args[:unit_language])
        update_fields(collection, [:archive_desc, :did, :repo, :corpname], args[:corp_name])
        update_fields(collection, [:archive_desc, :did, :repo, :corpname, :subarea], args[:subarea])
        update_fields(collection, [:archive_desc, :did, :repo, :address, :addressline], args[:unit_address])
        update_fields(collection, [:archive_desc, :accessrestrict], args[:access_restrict_info])
        update_fields(collection, [:archive_desc, :accessrestrict, :head], args[:access_restrict_head])
        update_fields(collection, [:archive_desc, :acqinfo], args[:acquisition_info])
        update_fields(collection, [:archive_desc, :acqinfo, :head], args[:acquisition_head])
        update_fields(collection, [:archive_desc, :prefercite], args[:prefercite_info])
        update_fields(collection, [:archive_desc, :prefercite, :head], args[:prefercite_head])
        collection.save
        exhibit= Exhibit.new(:namespace=>get_namespace)#(:pid=>pid)
        exhibit.update_indexed_attributes({:facets=>{0=>"dsc_0_collection_0_did_0_unittitle_0_imprint_0_publisher_facet",1=>"dsc_0_collection_0_did_0_unittitle_0_unittitle_content_facet"}})
        exhibit.update_indexed_attributes(:query=>{0=>"id_t:RBSC-CURRENCY"})
        exhibit.datastreams["rightsMetadata"].update_permissions({"group"=>{"archivist"=>"edit","public"=>"read"}})
        exhibit.collections_append(collection)
        exhibit.save
      else
        objmap = result.to_a[0]
        log.info("Collection already exists with Id: #{objmap["id"]}. Cannot create duplicate object")
      end
    end
    def page_ingest_each_row(row, filename)
      log.info("Rows: #{row.inspect}")
      if (row[0].blank? || row[1].blank?)
        raise "This entry #{row.inspect} has empty collection information"
      else
        image_id = row[0]
        item_id = row[1]
        image_title = row[3]
        image_name = row[4]
        key = "PAGE_#{image_id}"
	src_filename = filename.split('/')
	image_file = filename.sub("#{src_filename[src_filename.size-2]}/#{src_filename[src_filename.size-1]}", "Currency_Scans_2008 (B786)/#{image_name.to_s.strip}")
        attributes= {:pid_key => key, :item_id => item_id, :page_id => page_id, :image_title => image_title, :image_name => image_name, :image_file => image_file}
        ingest_page('page', attributes)
      end
    end
   
    def ingest_page(content_type, args)
      af_model = retrieve_af_model(content_type)
      unless af_model
        af_model = Page
      end
      item_check = Component.find_by_fields_by_solr({"item_did_unitid_s"=>args[:item_id]})
      if(item_check.to_a.length > 0)
	page_check = Page.find_by_fields_by_solr({"name_s"=>args[:image_name]})
	if(page_check.to_a.length < 1)
          map = Hash.new
          image_path = args[:image_file]
	  if(File.exists?(image_path))
            log.info(image_path)
            map[:file] = File.new(image_path)
            map[:mimeType] = "image/jpg"
            map[:file_name] = args[:image_name]
            map[:label] = "#{args[:image_title]}-#{args[:image_name]}"
            page= af_model.new(:namespace=>get_namespace)#(:pid=>pid)
	    page.update_indexed_attributes({:page_id=>{0=>args[:page_id]}})
	    page.update_indexed_attributes({:title=>{0=>args[:image_title]}})
	    page.update_indexed_attributes({:name=>{0=>args[:image_name]}})
            page.content = map
    	    page.item_append(item_check.to_a[0]["id"])
            page.save
            page.derive_all
            page.save
            page.datastreams["rightsMetadata"].update_permissions({"group"=>{"archivist"=>"edit","public"=>"read"}})
	    page.save
	    if(args[:image_name].to_s.strip.end_with? "front.jpg")
	      parent = Component.load_instance(item_check.to_a[0]["id"])
	      parent.update_indexed_attributes({:main_page=>{0=>page.pid}})
	      parent.save
	    end
	  else
	    log.info("Image not found: #{args[:image_name]}")
	  end
	else
	  log.info("Page already exists with Id:#{page_check.to_a[0]["id"]}")
	end
      else
	log.error("Couldn't find Item: #{args[:item_id]} for the image: #{args[:image_name]}.... Cannot create the page object....")
      end
    end
    
    def subcollection_ingest_each_row(row)
      log.info("Rows: #{row.inspect}")
      if (row[0].blank? || row[1].blank?)
         log.info("This entry #{row.inspect} has empty collection information, skip to next row")
      else
        key=row[1]
        abr_title = row[0]
        id = key
        printer=row[9]
        engraver=row[5]
        title=row[11] #row[8]
        geog=row[10]
        publisher=row[6]
        date=row[8] #row[11]
        description=row[4]
        display=row[3]
        genreform=row[2]
        subcol_id = row[13] #"SUBCOLLECTION_#{key}"
        attributes= {:key => subcol_id, :abr_title=> abr_title, :title => title, :subcollection_id => id, :genreform => genreform, :display => display, :date => date, :description => description, :publisher => publisher, :geography => geog, :printer => printer, :engraver => engraver}
        ingest_subcollection('component', attributes)
        log.info("Attributes: #{attributes.inspect}")
      end
    end
    
    def ingest_subcollection(content_type, args)
      af_model = retrieve_af_model(content_type)
      unless af_model
        af_model = Component
      end
#      pid= generate_pid(args[:pid_key], nil)
#      if(!asset_available(pid,content_type))
        #hard coding the Eadid as there is only one Collection header at this point of time....
        map = {"EAD_HEADER_0_EADID_T".downcase=>"american_colonial_currency"}
        result = Collection.find_by_fields_by_solr(map)
        log.info("Length of the search result: #{result.to_a.size}")
        if(result.to_a.size > 0)
          col_map = Component.find_by_fields_by_solr({"dsc_collection_did_unitid_unitid_identifier_s"=>args[:subcollection_id]})
          if(col_map.to_a.size < 1)
            subcollection= af_model.new(:namespace=>get_namespace)#(:pid=>pid, :component_level => "c01")
            subcollection.datastreams["descMetadata"].ng_xml = EadXml.subcollection_template
            subcollection.save
            subcollection.member_of_append(result.to_a[0]["id"])
            subcollection.save
            desc = Iconv.conv('utf-8','ISO-8859-1',args[:description])
            c = Iconv.new('UTF-8','ISO-8859-1')
            utf_desc = c.iconv(desc)
            subcollection.datastreams["rightsMetadata"].update_permissions({"group"=>{"archivist"=>"edit","public"=>"read"}})
            update_fields(subcollection, [:dsc, :collection, :did, :unitid], args[:abr_title])
            update_fields(subcollection, [:dsc, :collection, :did, :unitid, :unitid_identifier], args[:subcollection_id])
            update_fields(subcollection, [:dsc, :collection, :did, :origination, :printer], args[:printer])
            update_fields(subcollection, [:dsc, :collection, :did, :origination, :engraver], args[:engraver])
            #subcollection.update_indexed_attributes ({term=>{"0"=>value}} )
            update_fields(subcollection, [:dsc, :collection, :did, :unittitle, :unitdate], args[:title]) #new stuff
            update_fields(subcollection, [:dsc, :collection, :did, :unittitle, :imprint, :geogname], args[:geography])
            update_fields(subcollection, [:dsc, :collection, :did, :unittitle, :imprint, :publisher], args[:publisher])
            update_fields(subcollection, [:dsc, :collection, :did, :unittitle, :unittitle_content], args[:date]) #new stuff
            update_fields(subcollection, [:dsc, :collection, :scopecontent], args[:description])#utf_desc
            update_fields(subcollection, [:dsc, :collection, :odd], args[:display])
            update_fields(subcollection, [:dsc, :collection, :controlaccess, :genreform], args[:genreform])
            subcollection.update_indexed_attributes({:subcollection_id=>{0=>args[:key]}})
            subcollection.update_indexed_attributes({:component_type=>{0=>"subcollection"}})
            subcollection.save
            log.info("\r\n#{subcollection.datastreams["descMetadata"].to_xml}\r\n")
          else
            objmap = col_map.to_a[0]
            log.info("Subcollection already exists with Id: #{objmap["id"]}. Cannot create duplicate object")
          end
        else
          log.error("Collection does not exist. Cannot create Item without Parent Object")
        end
#      end
    end

    def item_ingest_each_row(row, filename)
      log.info("Rows: #{row.inspect}")
      if (row[0].blank? || row[1].blank?)
         log.info("This entry #{row.inspect} has empty item information, skip to next row")
      else
        key="ITEM_#{row[1]}"
        serial_number = row[12]
        item_id = row[1]
        collection_id = row[16]
        description = row[3].to_s
        provenance = row[11]
        physdesc = row[5]
        signer = row[4]
        title = row[14]
        display_title = row[0].to_s
        plate_letter = row[10]
        page_turn = row[9]
        #Get the image names and signers name for the item from the respective files
	src_filename = filename.split('/')
        images = load_dependency_file(item_id.to_s, filename.sub(src_filename[src_filename.size-1], "Image_Set.csv"))
        signers = load_dependency_file(item_id.to_s, filename.sub(src_filename[src_filename.size-1], "Signers_Set.csv"))
        display_signer = ""
        count = 1
        for i in signers
          if(count < (signers.size))
            display_signer += "#{i.to_s}, "
          else
            display_signer += "#{i.to_s}"
          end
          count += 1
        end
	log.info("Signers: #{display_signer}")
#        log.info("Converted to: key ->#{key}, item_id ->#{serial_number}, collection_id -> #{collection_id}")
        attributes= {:pid_key => key, :subcollection_id => collection_id, :display_title => display_title, :title => title, :item_id => item_id, :serial_number => serial_number, :display_signer => display_signer, :signer => signer, :physdesc => physdesc, :description => description, :plate_letter => plate_letter, :page_turn => page_turn, :provenance => provenance}
        ingest_item('component', attributes, images)
        log.info("Attributes: #{attributes.inspect}")
      end
    end

    def ingest_item(content_type, args, images)
      af_model = retrieve_af_model(content_type)
      unless af_model
        af_model = Component
      end
	log.info("Description: #{args[:description]}")
#      pid= generate_pid(args[:pid_key], nil)
#      if(!asset_available(pid,content_type))
	desc = Iconv.conv('utf-8','ISO-8859-1',args[:description])
        c = Iconv.new('UTF-8','ISO-8859-1')
        utf_desc = c.iconv(desc)
        result = Component.find_by_fields_by_solr({"subcollection_id_s"=>args[:subcollection_id]})
        if(result.to_a.length > 0)
          item_check = Component.find_by_fields_by_solr({"item_did_unitid_s"=>args[:item_id]})
          if(item_check.to_a.length < 1)
            item= af_model.new(:namespace=>get_namespace)#(:pid=>pid, :component_level => "c02")
            item.datastreams["descMetadata"].ng_xml = EadXml.item_template
            item.save
	    item.member_of_append(result.to_a[0]["id"])
	    item.update_indexed_attributes({:item_id=>{0=>args[:item_id]}})
            item.update_indexed_attributes({:component_type=>{0=>"item"}})
            item.save
            disp = args[:display_title].nil? ? "" : args[:display_title]
            item.datastreams["rightsMetadata"].update_permissions({"group"=>{"archivist"=>"edit","public"=>"read"}})
            update_fields(item, [:item, :did, :unitid], args[:item_id])
            update_fields(item, [:item, :did, :origination, :persname, :persname_normal], args[:display_signer])
            update_fields(item, [:item, :did, :origination, :persname], args[:signer])
            update_fields(item, [:item, :did, :unittitle], args[:title])
            update_fields(item, [:item, :did, :unittitle, :unittitle_label], args[:display_title])
            update_fields(item, [:item, :did, :unittitle, :num], args[:serial_number])
            update_fields(item, [:item, :did, :physdesc, :dimensions], args[:physdesc])
            update_fields(item, [:item, :scopecontent], args[:description])
            update_fields(item, [:item, :controlaccess, :genreform], args[:page_turn])
            update_fields(item, [:item, :odd], args[:plate_letter])
            update_fields(item, [:item, :acqinfo], args[:provenance])
            item.save
            counter = 1
            for i in images
              if(counter > 1)
                inserted_node, new_node_index = item.insert_new_node('image', opts={})
              end
              update_image_fields(item, [:item, :daogrp, :daoloc, :daoloc_href], "#{i.to_s}", (counter - 1).to_s)
              counter += 1
            end
            item.save
          else
            log.info("Item already exists with Id: #{item_check.to_a[0]["id"]}. Cannot create duplicate object")
          end
        else
          log.error("Subcollection does not exist. Cannot create Item without Parent Object")
        end
#      end
    end

    def load_dependency_file(id,file)
      log.info("inside load_signer for #{file}")
      data_arr = Array.new
      if File.exists? (file)
        arr_of_data = FasterCSV.read(file, :headers=>false)
        arr_of_data.each do |row|
          if(file.include? "Image")
            if((row[1].to_s).eql?(id))
              if(!((row[4].to_s).end_with? "tmb.jpg"))
                data_arr.push(row[4].to_s)
                log.info("Image_Title: #{row[4].to_s}")
	      end
            end
          else
            if((row[0].to_s).eql?(id))
              if(!((row[1].to_s).include? "Thumb"))
                data_arr.push(row[1].to_s)
                log.info("Signers: #{row[1].to_s}")
              end
            end
          end
        end
      end
      return data_arr
    end

    def update_fields(obj, term, value)
      obj.update_indexed_attributes ({term=>{"0"=>value}} )
      #obj.save
    end
    
    def update_image_fields(obj, term, value, counter)
      obj.update_indexed_attributes ({term=>{"#{counter.to_s}"=>value}} )
      #obj.save
    end
        
    def delete_all_obj_from_fedora(namespace)
      row =1
      while row < 717  do
        remove_each_obj(namespace,row)
        row +=1;
      end
    end

    def remove_each_obj(namespace,row)
      row_str=row
      pid= namespace+":" +row_str.to_s
      log.info("The pid is #{pid}")
      delete_object(pid)
    end
    
    def delete_object(pid)
      begin
        ActiveFedora::Base.load_instance(pid).delete
      rescue Exception => exc
        logger.error("Message for the log file #{exc.message}")
      end
    end

  end
end
