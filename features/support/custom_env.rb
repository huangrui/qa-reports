
#require 'capybara/envjs'
Capybara.ignore_hidden_elements = true
Capybara.server_boot_timeout = 30
#Capybara.javascript_driver = :selenium
Capybara.javascript_driver = :webkit

Before do
  load "#{Rails.root}/db/seeds.rb"
end
