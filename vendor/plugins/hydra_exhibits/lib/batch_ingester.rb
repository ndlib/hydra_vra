require 'rubygems'
require 'fastercsv'
require 'iconv'
require "#{RAILS_ROOT}/vendor/plugins/hydra_repository/lib/mediashelf/active_fedora_helper.rb"
require "#{RAILS_ROOT}/vendor/plugins/hydra_repository/app/helpers/application_helper.rb"
module BatchIngester
  class CurrencyIngester
    include MediaShelf::ActiveFedoraHelper
    include ApplicationHelper

    def process_ingest_data(filename)
      cnter = 1
      arr_of_data=load_file(filename)
      arr_of_data.each do |row|
        if(filename.include? "Collection")
          puts "Ingesting Subcollection Object"
          subcollection_ingest_each_row( row )
        elsif(filename.include? "Item")
          puts "Ingesting Item Object"
          item_ingest_each_row( row )
        elsif(filename.include? "Image")
          puts "Ingesting Page Object"
          page_ingest_each_row( row )
        elsif(filename.include? "Header")
          if cnter >1
            puts "Ingesting Ead Collection Object"
            collection_ingest_each_row( row )
          end
          cnter += 1
        else
          puts "Did not recognize Object"
        end
      end
    end

    def load_file(csv_file)
      if File.exists? (csv_file)
        arr_of_data = FasterCSV.read(csv_file, :headers=>false)
        puts "Ingest or Remove  #{arr_of_data.length}  Objects"
        return arr_of_data
      else
        puts "#{csv_file} does not exists!"
      end
    end
    def collection_ingest_each_row(row)
      puts "Rows: #{row.inspect}"
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
        attributes= {:pid_key => key, :ead_id => ead_id, :title => title, :author => author, :publisher => publisher, :creator => creation_person, :creation_date => creation_date, :address => address, :date => date, :langusage => langusage, :language => language, :unit_title => unit_title, :unit_head => unit_head, :unit_id => unit_id, :unit_date => unit_date, :unit_language => unit_language, :corp_name => corp_name, :subarea => subarea, :unit_address => unit_address, :access_restrict_head => access_restrict_head, :access_restrict_info => access_restrict_info, :prefercite_head => prefercite_head, :prefercite_info => prefercite_info}
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
      puts "Length of the search result: #{result.to_a.size}"
      if(result.to_a.size < 1)
        collection= af_model.new(:namespace=>"RBSC-CURRENCY")#(:pid=>pid)
        collection.datastreams["descMetadata"].ng_xml = EadXml.collection_template
        collection.save
        collection.datastreams["rightsMetadata"].update_permissions({"group"=>{"archivist"=>"edit"}})
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
	      update_fields(collection, [:archive_desc, :acqinfo], args[:prefercite_info])
        update_fields(collection, [:archive_desc, :acqinfo, :head], args[:prefercite_head])
        update_fields(collection, [:archive_desc, :prefercite], args[:prefercite_info])
        update_fields(collection, [:archive_desc, :prefercite, :head], args[:prefercite_head])
        collection.save
      else
        objmap = result.to_a[0]
        puts "Collection already exists with Id: #{objmap["id"]}. Cannot create duplicate object"
      end
    end
    def page_ingest_each_row(row)
      puts "Rows: #{row.inspect}"
      if (row[0].blank? || row[1].blank?)
        raise "This entry #{row.inspect} has empty collection information"
      else
        image_id = row[0]
        item_id = row[1]
        image_title = row[3]
        image_name = row[4]
        key = "PAGE_#{image_id}"
        attributes= {:pid_key => key, :item_id => item_id, :image_title => image_title, :image_name => image_name}
        ingest_page('page', attributes)
      end
    end
   
    def ingest_page(content_type, args)
      af_model = retrieve_af_model(content_type)
      unless af_model
        af_model = Page
      end
      pid= generate_pid(args[:pid_key], nil)
      if(!asset_available(pid,content_type))
        map = Hash.new
        image_path = "/Path/of/the/image/dir/#{args[:image_name]}"#"/home/rbalekai/Desktop/hydra_images/#{args[:image_name]}"
        map[:file] = File.new(image_path)
        map[:mimeType] = "image/jpg"
        map[:file_name] = args[:image_name]
        map[:label] = "#{args[:image_title]}-#{args[:image_name]}"
        page= af_model.new(:namespace=>"RBSC-CURRENCY")#(:pid=>pid)
        page.content = map
        item_pid = generate_pid("ITEM_#{args[:item_id]}",nil)
        page.item_append(item_pid)
        page.save
        page.derive_all
        page.save
      end
    end
    
    def subcollection_ingest_each_row(row)
      puts "Rows: #{row.inspect}"
      if (row[0].blank? || row[1].blank?)
         raise "This entry #{row.inspect} has empty collection information"
      else
        key=row[1]
        abr_title = row[0]
        id = key
        printer=row[9]
        engraver=row[5]
        title=row[8]
        geog=row[10]
        publisher=row[6]
        date=row[11]
        description=row[4]
        display=row[3]
        genreform=row[2]
        key = "SUBCOLLECTION_#{key}"
        attributes= {:pid_key => key, :abr_title=> abr_title, :title => title, :subcollection_id => id, :genreform => genreform, :display => display, :date => date, :description => description, :publisher => publisher, :geography => geog, :printer => printer, :engraver => engraver}
        ingest_subcollection('component', attributes)
        puts "Attributes: #{attributes.inspect}"
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
        puts "Length of the search result: #{result.to_a.size}"
        if(result.to_a.size > 0)
          col_map = Component.find_by_fields_by_solr({"dsc_collection_did_unitid_unitid_identifier_s"=>args[:subcollection_id]})
          if(col_map.to_a.size < 1)
            subcollection= af_model.new(:namespace=>"RBSC-CURRENCY")#(:pid=>pid, :component_level => "c01")
            subcollection.datastreams["descMetadata"].ng_xml = EadXml.subcollection_template
            subcollection.save
            subcollection.member_of_append(result.to_a[0]["id"])
            subcollection.save
            desc = Iconv.conv('utf-8','ISO-8859-1',args[:description])
            c = Iconv.new('UTF-8','ISO-8859-1')
            utf_desc = c.iconv(desc)
            subcollection.datastreams["rightsMetadata"].update_permissions({"group"=>{"archivist"=>"edit"}})
            update_fields(subcollection, [:dsc, :collection, :did, :unitid], args[:abr_title])
            update_fields(subcollection, [:dsc, :collection, :did, :unitid, :unitid_identifier], args[:subcollection_id])
            update_fields(subcollection, [:dsc, :collection, :did, :origination, :printer], args[:printer])
            update_fields(subcollection, [:dsc, :collection, :did, :origination, :engraver], args[:engraver])
            #subcollection.update_indexed_attributes ({term=>{"0"=>value}} )
            update_fields(subcollection, [:dsc, :collection, :did, :unittitle, :imprint, :publisher], args[:publisher])
            update_fields(subcollection, [:dsc, :collection, :did, :unittitle], args[:title])
            update_fields(subcollection, [:dsc, :collection, :scopecontent], utf_desc)
            update_fields(subcollection, [:dsc, :collection, :odd], args[:display])
            update_fields(subcollection, [:dsc, :collection, :controlaccess, :genreform], args[:genreform])
            
              
            subcollection.save
            puts "\r\n#{subcollection.datastreams["descMetadata"].to_xml}\r\n"
          else
            objmap = result.to_a[0]
            puts "Subcollection already exists with Id: #{objmap["id"]}. Cannot create duplicate object"
          end
        else
          puts "Collection does not exist. Cannot create Item without Parent Object"
        end
#      end
    end

    def item_ingest_each_row(row)
      puts "Rows: #{row.inspect}"
      if (row[0].blank? || row[1].blank?)
         raise "This entry #{row.inspect} has empty item information"
      else
        key="ITEM_#{row[1]}"
        serial_number = row[12]
        item_id = row[1]
        collection_id = row[16]
        description = row[3]
        provenance = row[11]
        physdesc = row[5]
        signer = row[4]
        title = row[14]
        display_title = row[0]
        plate_letter = row[12]
        page_turn = row[9]
        #Get the image names and signers name for the item from the respective files
        # image names in Image_partila_Set.csv and singers in Signers_partial_Set.csv in the shared directory
        images = load_dependency_file(item_id.to_s, "/home/rbalekai/Desktop/Image_Set.csv")
        signers = load_dependency_file(item_id.to_s, "/home/rbalekai/Desktop/Signers_Set.csv")
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
        puts "Converted to: key ->#{key}, item_id ->#{serial_number}, collection_id -> #{collection_id}"
        attributes= {:pid_key => key, :subcollection_id => collection_id, :dispay_title => display_title, :title => title, :item_id => item_id, :serial_number => serial_number, :display_signer => display_signer, :signer => signer, :physdesc => physdesc, :description => description, :plate_letter => plate_letter, :page_turn => page_turn, :provenance => provenance}
        ingest_item('component', attributes, images)
        puts "Attributes: #{attributes.inspect}"
      end
    end

    def ingest_item(content_type, args, images)
      af_model = retrieve_af_model(content_type)
      unless af_model
        af_model = Component
      end
      pid= generate_pid(args[:pid_key], nil)
      if(!asset_available(pid,content_type))
        result = Component.find_by_fields_by_solr({"dsc_collection_did_unitid_unitid_identifier_s"=>args[:subcollection_id]})
        if(result.to_a.length > 0)
          item_check = Component.find_by_fields_by_solr({"item_did_unitid_s"=>args[:item_id]})
          if(item_check.to_a.length < 1)
            item= af_model.new(:namespace=>"RBSC-CURRENCY")#(:pid=>pid, :component_level => "c02")
            item.datastreams["descMetadata"].ng_xml = EadXml.item_template
            item.save
            subcollection_pid = generate_pid("SUBCOLLECTION_#{args[:subcollection_id]}",nil)
            item.members_append(subcollection_pid)
            item.save
            disp = args[:display_title].nil? ? "" : args[:display_title]
            item.datastreams["rightsMetadata"].update_permissions({"group"=>{"archivist"=>"edit"}})
            update_fields(item, [:item, :did, :unitid], args[:item_id])
            update_fields(item, [:item, :did, :origination, :signer, :persname_normal], args[:display_signer])
            update_fields(item, [:item, :did, :origination, :signer], args[:signer])
            update_fields(item, [:item, :did, :unittitle], args[:title])
            update_fields(item, [:item, :did, :unittitle, :unittitle_label], disp)
            update_fields(item, [:item, :did, :unittitle, :num], args[:serial_number])
            update_fields(item, [:item, :did, :physdesc, :dimensions], args[:physdesc])
            update_fields(item, [:item, :scopecontent], args[:description])
            update_fields(item, [:item, :controlaccess, :genreform], args[:page_turn])
            update_fields(item, [:item, :odd], args[:plate_letter])
            update_fields(item, [:item, :acqinfo], args[:provenance])
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
            puts "Item already exists with Id: #{item_check.to_a[0]["id"]}. Cannot create duplicate object"
          end
        else
          puts "Subcollection does not exist. Cannot create Item without Parent Object"
        end
      end
    end

    def load_dependency_file(id,file)
      puts "inside load_signer for #{file}"
      data_arr = Array.new
      if File.exists? (file)
        arr_of_data = FasterCSV.read(file, :headers=>false)
        arr_of_data.each do |row|
          if(file.include? "Image")
            if((row[1].to_s).eql?(id))
              data_arr.push(row[3].to_s)
              puts "Image_Title: #{row[3].to_s}"
            end
          else
            if((row[0].to_s).eql?(id))
              if(!((row[1].to_s).include? "Thumb"))
                data_arr.push(row[1].to_s)
                puts "Signers: #{row[1].to_s}"
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
        
    def process_delete_obj(filename)
      arr_of_data=load_file(filename)
      arr_of_data.each do |row|
        remove_each_row( row )
      end
    end
    def remove_each_row(row)
      if (row[0].blank? || row[1].blank?)
        raise "This entry #{row.inspect} has empty street name or street number, Please correct it before proceeding"
      else
        key=row[0]<<'-'<<row[1]
        pid= generate_pid(key, nil)
        puts "The pid is #{pid}"
        delete_object(pid, "building")
      end
    end
    
    def delete_object(pid, content_type)      
      if(asset_available(pid,content_type))
          ActiveFedora::Base.load_instance(pid).delete
      end
    end
  end
end
