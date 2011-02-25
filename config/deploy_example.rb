#set all tasks from RAILS_ROOT using: cap -T

#############################################################
#  Application
#############################################################

set :application, 'application_name'

#############################################################
#  Settings
#############################################################

default_run_options[:pty] = true
set :use_sudo, false

#############################################################
#  Github
#############################################################

set :repository, "git://github.com/url"
set :scm, :git
set :branch, "master"
set :deploy_via, :remote_cache

#############################################################
#  Environments
#############################################################

desc "Setup for the Staging environment"
task :staging do
  set :rails_env,     'staging'
  set :rake,          '/shared/ruby/bin/rake'
  set :bundler,       '/shared/ruby/bin/bundle'
  set :deploy_to,     "/#{deploy_path}/#{application}"
  set :user,          'rails'
  set :domain,        'domain name'
  set :site_url,      'siteurl'
  set :app_server,    'passenger'

  server "#{user}@#{domain}", :app, :web, :db, :primary => true
end

desc "Setup for the Pre-Production environment"
task :pre_production do
  set :rails_env,      'pre_production'
  # NOTE the local svn command must also be available at the remote svn command path, a symlink may be necessary
  #set :scm_command,    '/shared/svn/binaries/bin/svn'
  set :rake,           '/shared/ruby187/bin/rake'
  set :bundler,        '/shared/ruby187/bin/bundle'
  set :deploy_to,      "/shared/ruby_server_pprd/data/app_home/#{application}"
  set :user,           'username'
  set :domain,         'domain name'
  set :site_url,       'site_url'
  set :app_server,     'server_name'

  server "#{user}@#{domain}", :app, :web, :db, :primary => true
end

#############################################################
#  Deploy
#############################################################

namespace :deploy do
  desc "Start application"
  task :start, :roles => :app do
    case app_server
    when "passenger"
      run "touch #{current_path}/tmp/restart.txt"    
    end
  end

  desc "Restart application"
  task :restart, :roles => :app do
    case app_server
    when "passenger"
      run "touch #{current_path}/tmp/restart.txt"    
    end
  end

  desc "Stop application"
  task :stop, :roles => :app do
    case app_server
    when "thin"
      run "/shared/ruby_server_pprd/admin/start_stop_hydrangea.sh stop"
    end
  end

  desc "Symlink shared configs and folders on each release."
  task :symlink_shared, :roles => :app do
    run "ln -nfs #{shared_path}/log #{release_path}/log"

    # Bundle management: when deployed use frozen gems
    # NOTE Update gems on the server with: bundle install --deployment
    run "ln -nfs #{shared_path}/bundle/config #{release_path}/.bundle/config"
    run "ln -nfs #{shared_path}/vendor/bundle #{release_path}/vendor/bundle"

    # NOTE configuration files should not be kept in source control for security reasons.
    ['database', 'solr', 'fedora'].each do |file|
      run "ln -nfs #{shared_path}/config/#{file}.yml #{release_path}/config/#{file}.yml"
    end

    # NOTE after the transition to mysql from sqlite remove the following line:
    run "ln -nfs #{shared_path}/db/#{rails_env}.sqlite3 #{release_path}/db/#{rails_env}.sqlite3"
  end

  desc "Install gems in Gemfile"
  task :bundle_install, :roles => :app do
    run "cd #{release_path} && #{bundler} install"
  end

  desc "Spool up Passenger spawner to keep user experience speedy"
  task :kickstart, :roles => :app do
    run "curl -I http://#{site_url}"
  end
end

after 'deploy:update_code', 'deploy:symlink_shared', 'deploy:bundle_install', 'deploy:migrate'
after 'deploy', 'deploy:cleanup'

