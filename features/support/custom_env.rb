
require 'capybara/envjs'
Capybara.ignore_hidden_elements = true
Capybara.javascript_driver = :envjs

require "#{Rails.root}/db/seeds.rb"
