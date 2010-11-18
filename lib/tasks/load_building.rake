namespace :load do
  desc "Load the building from csv file"

  task :load_csv_data  => :environment do
    ingester = Ingester::SeasideIngester.new
    if ENV['FILE']
      ingester.process_ingest_data(ENV['FILE'])
    else
      ingester.process_ingest_data("spec/fixtures/seaside.csv")
    end
  end

  desc "Remove building from csv file"
  task :remove_csv_objects  => :environment do
    ingester = Ingester::SeasideIngester.new
    if ENV['FILE']
      ingester.process_delete_obj(ENV['FILE'])
    else
      ingester.process_delete_obj("spec/fixtures/seaside.csv")
    end

  end

end