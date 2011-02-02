# Must be set before requireing multisage
set :default_stage, "staging"
require 'capistrano/ext/multistage'
require 'config/deploy/capistrano_database_yml'
require 'bundler/capistrano'
require 'yaml'

set :use_sudo, false
set :copy_compression, :zip

set :scm, :git
set :repository, "http://git.gitorious.org/meego-quality-assurance/qa-reports.git"
set :deploy_via, :remote_cache

ssh_options[:forward_agent] = true

# If you have previously been relying upon the code to start, stop
# and restart your mongrel application, or if you rely on the database
# migration code, please uncomment the lines you require below

# If you are deploying a rails app you probably need these:

# load 'ext/rails-database-migrations.rb'
# load 'ext/rails-shared-directories.rb'

# There are also new utility libaries shipped with the core these
# include the following, please see individual files for more
# documentation, or run `cap -vT` with the following lines commented
# out to see what they make available.

# load 'ext/spinner.rb'              # Designed for use with script/spin
# load 'ext/passenger-mod-rails.rb'  # Restart task for use with mod_rails
# load 'ext/web-disable-enable.rb'   # Gives you web:disable and web:enable

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:

# If you aren't using Subversion to manage your source code, specify
# your SCM below:

after "deploy:setup" do
  # Create shared directories
  run "mkdir -p #{shared_path}/reports"
  run "mkdir -p #{shared_path}/files"
  run "mkdir -p #{shared_path}/reports/tmp"

  # Create newrelic configuration file
  enable_newrelic = Capistrano::CLI::ui.ask("Do you want to enable NewRelic performance monitoring? Please note this sends data to external service. Default: no")
  newrelic_config = YAML.load_file("config/newrelic.yml") 
  if enable_newrelic =~ /yes/i
    newrelic_config["production"]["monitor_mode"] = true
    newrelic_config["staging"]["monitor_mode"] = true
  end
  put YAML::dump(newrelic_config), "#{shared_path}/config/newrelic.yml"
  
  # Create registeration token
  registeration_token = Capistrano::CLI::ui.ask("What registeration token you want to use? (/users/<token>/register). Default: none")
  put registeration_token, "#{shared_path}/config/registeration_token"

  # Create Exception Notifier email list
  email_addresses = Capistrano::CLI::ui.ask("Which email addresses should be notified in case of application errors? (Space separated list of email addresses)")
  put "%w{#{email_addresses}}", "#{shared_path}/config/exception_notifier"
end

after "deploy:symlink" do
  # Remove local directories
  run "rm -fr #{current_path}/public/reports"
  
  # Link to shared folders
  run "ln -nfs #{shared_path}/reports #{current_path}/public/"
  run "ln -nfs #{shared_path}/files #{current_path}/public/"

  # Remove empty token file that comes with deployment and symlink to shared
  run "rm -rf #{current_path}/config/registeration_token"
  run "ln -nfs #{shared_path}/config/registeration_token #{current_path}/config/registeration_token"

  # Remove current newrelic config file and symlink to shared
  run "rm #{current_path}/config/newrelic.yml"
  run "ln -nfs #{shared_path}/config/newrelic.yml #{current_path}/config/newrelic.yml"

  # Symlink exception notifier config to shared
  run "ln -nfs #{shared_path}/config/exception_notifier #{current_path}/config/exception_notifier"
end

namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "Start the app server"
  task :start, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

end

