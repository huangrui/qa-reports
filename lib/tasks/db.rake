require 'rubygems'

namespace :db do
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

  task :import do
    if Rails.env == 'production'
      raise "ERROR: Your should run db:import only in development environment"
    end

    `cap production db:dump`
    `bunzip2 qa_reports_production.sql.bz2`

    db_conf = YAML.load_file('config/database.yml')[Rails.env]
    `mysql \
        -u #{db_conf['username']} \
        -p#{db_conf['password']} \
        #{db_conf['database']} \
        < qa_reports_production.sql`

    `rm qa_reports_production.sql`
  end

end

