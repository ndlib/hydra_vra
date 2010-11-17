require 'rubygems'
require 'fastercsv'
module Ingester
  class SeasideIngester
    include MediaShelf::ActiveFedoraHelper
    def load_file(csv_file)
      if File.exists? (csv_file)
        arr_of_data = FasterCSV.read(csv_file, :headers=>false)
        puts "Ingesting  #{arr_of_data.length} to fedora"
        arr_of_data.each do |row|
          process_each_row( row )
	      end
      else
        puts "#{csv_file} does not exists!"
      end
    end

    def process_each_row(row)
      puts "Rows: #{row.inspect}"
      if (row[0].blank? || row[1].blank?)
         raise "This entry #{row.inspect} has empty street name or street number, Please correct it before proceeding"
      else
        key=row[0]<<'-'<<row[1]
        architect_name=(row[2].blank? ? '' : row[2])<<(row[3].blank? ? '' : (','<<row[3]) )
        title= (row[4].blank? ? '' : row[4])
        puts "Converted to: key ->#{key}, architect_name ->#{architect_name}, cottage_name -> #{title}"
        attributes= {:pid_key => key, :title => title, :architect_name => architect_name}
        create_content_model('building', attributes)
        puts "Attributes: #{attributes.inspect}"
      end
    end

    def create_content_model(content_type, args)
       af_model = retrieve_af_model(content_type)
      unless af_model
        af_model = Building
      end
      pid= generate_pid(args[:pid_key], nil)
        puts "The pid is #{pid}"
        if(!asset_available(pid,content_type))
          puts "Need to create new Obj"
          building= af_model.new({:pid=>pid})
          puts"New Fedora Obj: #{building.pid}"
          building.save
          #give permission
          #building. apply_depositor_metadata("archivist1")
          building.datastreams["rightsMetadata"].update_permissions({"group"=>{"archivist"=>"edit"}})
          #update values for the building
          #building.update_indexed_attributes( {[:work, :title_set,:title_display]=>{"0"=>args[:title]}} )
          update_fields(building, [:work, :title_set,:title_display], args[:title])
          update_fields(building, [:work, :agent_set,:agent_display], args[:architect_name])
          #building.update_indexed_attributes( {[:work, :agent_set,:agent_display]=>{"0"=>args[:architect_name]}} )
          #Populate agent node here
          update_fields(building, [:work, :agent_set, {:agent=>0},:name], args[:architect_name])
          #building.update_indexed_attributes( {[:work, :agent_set, {:agent=>0},:name]=>{"0"=>args[:architect_name]}} )
          building.save
        else
          building= af_model.load_instance(pid.to_s)
          architect_list=building.datastreams["descMetadata"].term_values(:work, :agent_set, :agent, :name)
          unless (architect_list.include?(args[:architect_name]))
            new_architect_list=   building.datastreams["descMetadata"].term_values(:work, :agent_set, :agent_display) << ";" << args[:architect_name]
            update_fields(building, [:work, :agent_set,:agent_display], new_architect_list)
            #Populate agent node here
            inserted_node, new_node_index = building.insert_new_node('agent', opts={})
            update_fields(building, [:work, :agent_set, {:agent=>new_node_index},:name], args[:architect_name])
            building.save
          end
        end
        puts "Update value is #{building.datastreams["descMetadata"].term_values(:work, :agent_set, :agent_display)}"
    end

    def update_fields(obj, term, value)
      obj.update_indexed_attributes({term=>{"0"=>value}} )
      #obj.save
    end
    
  end
end
