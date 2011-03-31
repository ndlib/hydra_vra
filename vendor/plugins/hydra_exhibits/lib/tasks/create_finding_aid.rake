namespace :batch do
  desc "Create the full finding aid"

  task :create_full_finding_aid  => :environment do
    puts "Creating Finding Aid"
    if ENV['COL']
      ingester = CreateFindingAid::FullFindingAid.build_xml(ENV['COL'])
    end
  end
end
