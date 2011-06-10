source 'http://rubygems.org'

gem 'rails'
gem 'mysql2'
gem 'nokogiri'
gem 'devise', '1.1.9'
gem 'fastercsv'
gem 'rack', :git => "https://github.com/rack/rack.git" # Use next release when available
gem "will_paginate"
gem 'slim'
gem 'paperclip'
gem 'coffee-script'
gem 'therubyracer', '0.9.0beta3', :require => false
gem 'rest-client', :require => 'rest_client'

group :production do
  gem 'newrelic_rpm'
end

group :development do
  gem 'sqlite3-ruby', :require => 'sqlite3'
  gem 'capistrano'
  gem 'capistrano-ext'
end

group :development, :test do 
  gem 'launchy'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'capybara', :git => "https://github.com/jnicklas/capybara.git"
  gem 'cucumber'
  gem 'rcov', :require => false
  gem 'cucumber-rails'
  gem 'metric_fu', :git => "https://github.com/pyykkis/metric_fu.git"
  gem 'database_cleaner'
end

