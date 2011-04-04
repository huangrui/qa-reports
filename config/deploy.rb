# Must be set before requireing multisage
set :default_stage, "staging"
require 'capistrano/ext/multistage'
require 'config/deploy/capistrano_database_yml'
require 'bundler/capistrano'
require 'yaml'

set :user, "www-data"
set :use_sudo, false
set :copy_compression, :zip

set :scm, :git
set :repository, "http://git.gitorious.org/meego-quality-assurance/qa-reports.git"
set :deploy_via, :remote_cache

ssh_options[:forward_agent] = true
ssh_options[:user] = "www-data"

after "deploy:setup" do
  # Create shared directories
  run "mkdir -p #{shared_path}/config"
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

  # Bugzilla configuration - only HTTP auth
  bugzilla_conf = YAML.load_file("config/bugzilla.yml")
  bugzilla_auth = Capistrano::CLI::ui.ask("Do you want to define HTTP credentials to access Bugzilla? Note that you should have a separate user account for this since the credentials are stored as plain text. Default: No")

  if bugzilla_auth =~ /yes/i
    bugzilla_uname = Capistrano::CLI::ui.ask("Please enter your HTTP username")
    bugzilla_passw = Capistrano::CLI::ui.ask("Please enter your HTTP password")
    bugzilla_conf["http_username"] = bugzilla_uname
    bugzilla_conf["http_password"] = bugzilla_passw
  end
  put YAML::dump(bugzilla_conf), "#{shared_path}/config/bugzilla.yml"

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
  
  # Remove current bugzilla config file and symlink to shared
  run "rm #{current_path}/config/bugzilla.yml"
  run "ln -nfs #{shared_path}/config/bugzilla.yml #{current_path}/config/bugzilla.yml"
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

