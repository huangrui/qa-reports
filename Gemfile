source 'http://rubygems.org'

gem 'rails', '~>3.0.9'
gem 'mysql2', '~>0.2.11' # 0.3 branch only works with rails 3.1
gem 'nokogiri'
gem 'devise', '1.1.9'
gem 'fastercsv'
#gem 'rack', :git => "https://github.com/rack/rack.git" # Use next release when available
gem "will_paginate"
gem 'slim'
gem 'paperclip'
gem 'coffee-script'
gem 'therubyracer', '~>0.9.0', :require => false
gem 'barista', '>= 0.5.0'
gem 'rest-client', :require => 'rest_client'
gem 'activerecord-import'
gem "rake"

group :production do
  gem 'newrelic_rpm'
end

group :development do
  gem 'capistrano'
  gem 'capistrano-ext'
  gem 'watchr'
end

group :development, :test do
  gem 'launchy'
  gem 'rspec', '~>2.5.0'
  gem 'rspec-rails'
  gem 'capybara', '0.4.1.2'
  gem 'cucumber'
  gem 'rcov', :require => false
  gem 'cucumber-rails', '~> 0.3.2' #newer ones fail
  gem 'metric_fu', :git => "https://github.com/pyykkis/metric_fu.git"
  gem 'database_cleaner'
end

