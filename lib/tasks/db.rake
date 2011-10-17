require 'rubygems'

namespace :db do

  desc "Dump database"
  task :dump do
    db_conf = YAML.load_file('config/database.yml')[Rails.env]
    `mysqldump \
        --add-drop-table \
        -u #{db_conf['username']} \
        -p#{db_conf['password']} \
        -h #{db_conf['host']} \
        #{db_conf['database']} | \
        bzip2 -c > qa_reports_production.sql.bz2`
  end

  desc "Import production database to local environment"
  task :import do
    if Rails.env == 'production'
      raise "ERROR: Your should not import data to production environment"
    end

    `bunzip2 qa_reports_production.sql.bz2`

    db_conf = YAML.load_file('config/database.yml')[Rails.env]
    `mysql \
        -u #{db_conf['username']} \
        -p#{db_conf['password']} \
        #{db_conf['database']} \
        < qa_reports_production.sql`

    `rm qa_reports_production.sql`
  end

  # Internal: Push production database to staging
  task :put_and_import_to_staging do
    `cap staging db:import`
    `rm qa_reports_production.sql.bz2`
  end

  # Internal: Push production files to staging
  task :put_and_import_files_to_staging do
    `cap staging db:import_files`
    `rm qa-reports-files.tar.gz`
  end

end
