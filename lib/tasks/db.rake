require 'rubygems'

namespace :db do
  task :dump do
    db_conf = YAML.load_file('config/database.yml')
    `mysqldump \
        --add-drop-table \
        -u #{db_conf[Rails.env]['username']} \
        -p#{db_conf[Rails.env]['password']} \
        -h #{db_conf[Rails.env]['host']} \
        #{db_conf[Rails.env]['database']} | \
        bzip2 -c > qa_reports_production.sql.bz2`
  end

  task :import do
    `cap production db:dump`
    `bunzip2 qa_reports_production.sql.bz2`

    db_conf = YAML.load_file('config/database.yml')
    `mysql \
        -u #{db_conf[::Rails.env]['username']} \
        -p#{db_conf[::Rails.env]['username']} \
        #{db_conf[::Rails.env]['database']} \
        < qa_reports_production.sql`
  end

end

