
#require 'capybara/envjs'
Capybara.ignore_hidden_elements = true
#Capybara.javascript_driver = :selenium

Before do
  load "#{Rails.root}/db/seeds.rb"
end
