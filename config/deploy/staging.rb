set :application, "qa-reports.qa.leonidasoy.fi"
set :deploy_to, "/home/#{user}/#{application}"
set :rails_env, "staging"

ssh_options[:port] = 31915

server "qa-reports.qa.leonidasoy.fi", :app, :web, :db, :primary => true

namespace :db do
  desc "Import production database to staging"
  task :import, :roles => :db, :only => {:primary => true} do
    upload "./qa_reports_production.sql.bz2", "#{current_path}/qa_reports_production.sql.bz2"
    run "cd #{current_path} && RAILS_ENV='#{rails_env}' rake db:import_to_db"
  end
end
