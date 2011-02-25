namespace :batch do
  desc "Load the building from csv file"

  task :load_csv_data  => :environment do
    puts "Inside load_csv_data"
    ingester = BatchIngester::CurrencyIngester.new
    if ENV['FILE']
      ingester.process_ingest_data(ENV['FILE'])
#    else
#      ingester.process_ingest_data("spec/fixtures/seaside.csv")
    end
  end

  desc "Remove building from csv file"
  task :remove_all_objects  => :environment do
    ingester = BatchIngester::CurrencyIngester.new
    if ENV['FILE']
      ingester.delete_all_obj_from_fedora(ENV['NAMESPACE'])
    else
      ingester.delete_all_obj_from_fedora("RBSC-CURRENCY")
    end

  end

  desc "Load data to staging"
  task :load_staging_objects  => ["staging", "batch:header", "batch:collection", "batch:items", "batch:images"]  

  desc "process ead header file from staging mount"
  task :header do
    ENV['FILE'] = '/mnt/inquisition/Currency\ ALL\ CSV\ files/Ead_Header.csv'
    puts "Processing  #{ENV['FILE']}"
    Rake::Task["batch:load_csv_data"].invoke
  end

  desc "process collection file from staging mount"
  task :collection do
    ENV['FILE'] = '/mnt/inquisition/Currency\ ALL\ CSV\ files/Collection_Set_Formatted.csv'
    puts "Processing  #{ENV['FILE']}"
    Rake::Task["batch:load_csv_data"].reenable
    Rake::Task["batch:load_csv_data"].invoke
  end

  desc "process items file from staging mount"
  task :items do
    ENV['FILE'] = '/mnt/inquisition/Currency\ ALL\ CSV\ files/Item_set_formatted.csv'
    puts "Processing  #{ENV['FILE']}"
    Rake::Task["batch:load_csv_data"].reenable
    Rake::Task["batch:load_csv_data"].invoke
  end

  desc "process images file from staging mount"
  task :images do
    ENV['FILE'] = '/mnt/inquisition/Currency\ ALL\ CSV\ files/Image_Set.csv'
    puts "Processing  #{ENV['FILE']}"
    Rake::Task["batch:load_csv_data"].reenable
    Rake::Task["batch:load_csv_data"].invoke
  end

  desc "testing the data sent"
  task :test_data  => :environment do
    puts "Inside test_data"
    puts "File to process #{ENV['FILE']} in environment #{RAILS_ENV}"
  end


end