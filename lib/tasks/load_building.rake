require 'application_helper'
include ApplicationHelper

namespace :load do
  desc "Load the building from csv file"

  task :load_csv_data  => :environment do
    ingester = Ingester::SeasideIngester.new
    ingester.load_file("spec/fixtures/seaside.csv")
=begin    require 'fastercsv'
    #FasterCSV.foreach("spec/fixtures/Seaside Architect.csv") do |row|
    FasterCSV.foreach("spec/fixtures/seaside.csv") do |row|
      puts "Rows: #{row.inspect}"
      if (row[0].blank? || row[1].blank?)
         raise "This entry #{row.inspect} has empty street name or street number, Please correct it before proceeding"
      else
        key=row[0]<<'-'<<row[1]
        architect_name=(row[2].blank? ? '' : row[2])<<(row[3].blank? ? '' : (','<<row[3]) )
        title= (row[4].blank? ? '' : row[4])
        puts "Converted to: key ->#{key}, architect_name ->#{architect_name}, cottage_name -> #{title}"
        pid= generate_pid(key, nil)
        puts "The pid is #{pid}"
        if(!asset_available(pid,"Building"))
          puts "Need to create new Obj"
          building= Building.new({:pid=>pid})
          puts"New Fedora Obj: #{building.pid}"
          #give permission
          #building. apply_depositor_metadata("archivist1")
          building.datastreams["rightsMetadata"].update_permissions({"group"=>{"archivist"=>"edit"}})
          #update values for the building
          building.update_indexed_attributes( {[:work, :title_set,:title_display]=>{"0"=>title}} )
          building.update_indexed_attributes( {[:work, :agent_set,:agent_display]=>{"0"=>architect_name}} )
          #Populate agent node here
          building.update_indexed_attributes( {[:work, :agent_set, {:agent=>0},:name]=>{"0"=>architect_name}} )
          building.save
        else
          building= Building.load_instance(pid.to_s)
          new_architect_list=   building.datastreams["descMetadata"].term_values(:work, :agent_set, :agent_display) << ";" << architect_name
          building.update_indexed_attributes( {[:work, :agent_set,:agent_display]=>{"0"=>new_architect_list}} )
          #Populate agent node here
          inserted_node, new_node_index = building.insert_new_node('agent', opts={})
          building.update_indexed_attributes( {[:work, :agent_set, {:agent=>new_node_index},:name]=>{"0"=>architect_name}} )
          building.save
        end
        puts "Update value is #{building.datastreams["descMetadata"].term_values(:work, :agent_set, :agent_display)}"
      end
    end
=end
  end

  desc "Remove building for the pid in csv file"
  task :remove_csv_objects  => :environment do
    require 'fastercsv'
    FasterCSV.foreach("spec/fixtures/seaside.csv") do |row|
      puts "Rows: #{row.inspect}"
      if (row[0].blank? || row[1].blank?)
         raise "This entry #{row.inspect} has empty street name or street number, Please correct it before proceeding"
      else
        key=row[0]<<'-'<<row[1]
        pid= generate_pid(key, nil)
        puts "The pid is #{pid}"
        if(asset_available(pid,"Building"))
          ActiveFedora::Base.load_instance(pid).delete
        end
      end
    end
  end

end