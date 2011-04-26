source 'http://rubygems.org'


gem 'rails'
gem 'mysql2'
gem 'nokogiri'
gem 'devise', '1.1.9'
gem 'fastercsv'
gem 'rack', :git => "https://github.com/rack/rack.git" # Use next release when available
gem "will_paginate"
gem 'slim'

group :production do
  gem 'newrelic_rpm'
end

group :development do
  gem 'sqlite3-ruby', :require => 'sqlite3'
  gem 'capistrano'
  gem 'capistrano-ext'
  gem 'autotest'
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

