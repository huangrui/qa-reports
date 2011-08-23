require 'rubygems'


namespace :db do

  desc "Import production database to development environment"
  task :import => [:dump_and_fetch_db, :import_to_db]

  desc "Import production database and files to development environment"
  task :import_all => [:import, :fetch_files, :import_files]

  desc "Import production database to staging environment"
  task :import_to_staging => [:dump_and_fetch_db, :put_and_import_to_staging]

  desc "Import production database and files to staging environment"
  task :import_all_to_staging => [:import_to_staging, :fetch_files, :put_and_import_files_to_staging]

  # Internal: Fetch production database to localhost
  task :dump_and_fetch_db do
    `cap production db:dump`
  end

  # Internal: Fetch files from production to localhost
  task :fetch_files do
    `cap production db:fetch_files`
  end

  # Internal: Run by capistrano on production server
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

  # Internal: Run on localhost or staging environment by capistrano
  task :import_to_db do
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

  task :import_files do
    `tar -xzf qa-reports-files.tar.gz && rm qa-reports-files.tar.gz`
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
