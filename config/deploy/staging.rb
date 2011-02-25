set :application, "meego.qa.leonidasoy.fi"
set :user, "leonidas"
set :rails_env, "staging"

# Use absolute paths in order to avoid problems with scp
set :deploy_to, "/home/#{user}/sites/#{application}"

ssh_options[:port] = 31915
ssh_options[:user] = "leonidas"

server "staging.leonidasoy.fi", :app, :web, :db, :primary => true

namespace :db do
  desc "Import production database to staging"
  task :import, :roles => :db, :only => {:primary => true} do
    put "./qa_reports_production.sql.bz2", "#{current_path}/qa_reports_production.sql.bz2"
    run "cd #{current_path} && RAILS_ENV='staging' rake db:import_to_db"
    run "rm #{current_path}/qa_reports_production.sql"
  end
end
