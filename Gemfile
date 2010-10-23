source 'http://rubygems.org'

gem 'rails', '3.0.0'

group :staging, :production do
  gem 'mysql'
end

group :development do
  gem 'sqlite3-ruby', :require => 'sqlite3'
  gem 'capistrano'
  gem 'capistrano-ext'
end

group :test do
  gem 'capybara'
  gem 'cucumber'
  gem 'culerity'
  gem 'celerity', :require => false
  gem 'launchy'
  gem 'cucumber-rails'
  gem 'rspec-rails', '>= 2.0.0.beta'
  gem 'ZenTest', '4.4.0'
  gem 'autotest'
  gem 'autotest-rails'
  gem 'metric_fu', :git => "git://github.com/pyykkis/metric_fu.git"
end

gem 'nokogiri'
gem 'bitly'
gem 'devise', '1.1.3'

