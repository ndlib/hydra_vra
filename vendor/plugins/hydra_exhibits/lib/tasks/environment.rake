#namespace :env do
  %w[development staging pre_production production].each do |env|
    desc "Runs the following task in the #{env} environment"
    task env do
      RAILS_ENV = ENV['RAILS_ENV'] = env
      puts "setting rails env to #{RAILS_ENV}"
    end
  end

  task :development do
    Rake::Task["development"].invoke
  end

  task :testing do
    RAILS_ENV = ENV['RAILS_ENV'] = 'test'
    puts "setting rails env to #{RAILS_ENV}"
  end

  task :staging do
    Rake::Task["staging"].invoke
  end

  task :pre_production do
    Rake::Task["pre_production"].invoke
  end

  task :production do
    Rake::Task["production"].invoke
  end



#end