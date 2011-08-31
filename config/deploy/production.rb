set :application, "qa-reports.meego.com"
set :deploy_to, "/home/#{user}/#{application}"
set :rails_env, "production"

ssh_options[:port] = 43398

server "qa-reports.meego.com", :app, :web, :db, :primary => true
host = roles[:db].servers.first.host

after "deploy:symlink" do
  # Allow robots to index qa-reports.meego.com
  run "rm #{current_path}/public/robots.txt"
  run "touch #{current_path}/public/robots.txt"
end

namespace :db do
  desc "Dump and fetch production database and uploaded files"
  task :dump, :roles => :db, :only => {:primary => true} do
    run "cd #{current_path} && RAILS_ENV='#{rails_env}' bundle exec rake db:dump"
    get "#{current_path}/qa_reports_production.sql.bz2", "./qa_reports_production.sql.bz2"
    run "rm #{current_path}/qa_reports_production.sql.bz2"
    `rsync --rsh="ssh -p #{ssh_options[:port]}" \
           --copy-links                         \
           --recursive                          \
           --verbose                            \
           --archive                            \
           --compress                           \
           #{user}@#{host}:#{current_path}/public/files/attachments public/files`
  end

  desc "Compress and fetch files"
  task :fetch_files, :roles => :db, :only => {:primary => true} do
    tarball    = "qa-reports-files.tar.gz"
    files_path = "./public/files/*"
    run "cd #{current_path} && tar -czf #{tarball} #{files_path}"
    get "#{current_path}/#{tarball}", "./#{tarball}"
    run "rm #{current_path}/#{tarball}"
  end
end
