# This is an example capistrano recipe for deploying blacklight. 
# We use it to deploy the application at demo.blacklightopac.org
# Your milage may vary for local usage. 

#set :application, "bl-demo"

# name of the user who will own this application on the server 
#set :user, "deployer"
# SVN repository from which to check out the code
#set :repository,  "svn+ssh://eos8d@rubyforge.org/var/svn/blacklight/trunk/rails"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/usr/local/projects/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

# If you run your app, your webserver (httpd) and/or your database on different servers, you can 
# set each of these to unique values
#set :domain, "polaris.lib.virginia.edu"
#role :app, domain
#role :web, domain
#role :db,  domain, :primary => true

#set :runner, "deployer"
#set :rails_env, "production"

# This assumes that your database.yml file is NOT in subversion,
# but instead is in your deploy_to/shared directory. Database.yml
# files should *never* go into subversion for security reasons.
#task :after_update_code do
#  run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
#  run "ln -nfs #{deploy_to}/shared/config/solr.yml #{release_path}/config/solr.yml"
#end


# List all tasks from RAILS_ROOT using: cap -T

#############################################################
#  Application
#############################################################

set :application, 'hydrangea'

#############################################################
#  Settings
#############################################################

default_run_options[:pty] = true
set :use_sudo, false

#############################################################
#  Subversion
#############################################################

set :scm, :subversion
set :svn_username, 'rails'
set :svn_password, 'r91lsf0rl1b'
set :repository,   "https://svn.library.nd.edu/svn_deploy/svn_ndlibs_devel/applications/#{application}/trunk --username #{svn_username} --password #{svn_password}"

#############################################################
#  Environments
#############################################################

desc "Setup for the Staging environment"
task :staging do
  set :rails_env,      'staging'
  set :scm_command,    '/usr/bin/svn'
  set :rake,           '/shared/ruby/bin/rake'
  set :deploy_to,      "/data/web_root/htdocs/rails_apps/#{application}"
  set :user,           'rails'
  set :domain,         'ambrosiana.library.nd.edu'
  set :site_url,       'afmstaging.library.nd.edu'

  server "#{user}@#{domain}", :app, :web, :db, :primary => true
end

# ========================
# For mod_rails apps
# ========================

#namespace :deploy do
#  task :start, :roles => :app do
#    run "touch #{deploy_to}/current/tmp/restart.txt"
#  end
#
#  task :restart, :roles => :app do
#    run "touch #{deploy_to}/current/tmp/restart.txt"
#  end
#
#  task :after_symlink, :roles => :app do
#    run "cp #{deploy_to}/current/vendor/plugins/blacklight/config/initializers/blacklight_config.rb #{deploy_to}/current/config/initializers/blacklight_config.rb"
#    # this next step shouldn't be necessary for rails 2.3, and yet the installation on polaris.lib won't
#    # run without it
#    run "ln -nfs #{deploy_to}/current/vendor/plugins/blacklight/app/controllers/application_controller.rb #{deploy_to}/current/vendor/plugins/blacklight/app/controllers/application.rb"
#
#    # reindex the data
#    run "cd #{deploy_to}/current; rake solr:marc:index MARC_FILE=/usr/local/projects/data/test_data.utf8.mrc SOLR_WAR_PATH=/usr/local/projects/solr/solr.war CONFIG_PATH=#{deploy_to}/current/vendor/plugins/blacklight/config/SolrMarc/demoserver.properties"
#    run "cd #{deploy_to}/current; rake app:index:ead_dir FILE=/usr/local/projects/data/ead/*.xml"
#  end
#end

#############################################################
#  Deploy
#############################################################

namespace :deploy do
  desc "Start application in Passenger"
  task :start, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "Restart application in Passenger"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Symlink shared configs and folders on each release."
  task :symlink_shared do
    run "ln -nfs #{shared_path}/log #{release_path}/log"
    run "ln -nfs #{shared_path}/db/#{rails_env}.sqlite3 #{release_path}/db/#{rails_env}.sqlite3"
  end

  desc "Spool up Passenger spawner to keep user experience speedy"
  task :kickstart do
    run "curl -I http://#{site_url}"
  end

  desc "Debug deployment process"
  task :debug do
    run "whoami"
    run "hostname"
    run "which svn"
    run "echo $PATH"
  end
end

after 'deploy:update_code', 'deploy:migrate', 'deploy:symlink_shared'
after 'deploy', 'deploy:cleanup'
