
#require 'capybara/envjs'
Capybara.ignore_hidden_elements = true
Capybara.server_boot_timeout = 30
#Capybara.javascript_driver = :selenium
Capybara.javascript_driver = :webkit

Before do
  load "#{Rails.root}/db/seeds.rb"
end

class Net::HTTP
  alias_method :old_initialize, :initialize
  def initialize(*args)
    old_initialize(*args)
    @ssl_context = OpenSSL::SSL::SSLContext.new
    @ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
end
