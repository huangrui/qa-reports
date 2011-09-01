set :application, "qa-reports.qa.leonidasoy.fi"
set :deploy_to, "/home/#{user}/#{application}"
set :rails_env, "staging"

ssh_options[:port] = 31915

server "qa-reports.qa.leonidasoy.fi", :app, :web, :db, :primary => true

namespace :db do
  desc "Import production database to staging"
  task :import, :roles => :db, :only => {:primary => true} do
    run "cap production db:export"
  end
end
