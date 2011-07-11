require 'rubygems'

begin
  require 'cucumber'
  require 'cucumber/rake/task'

  namespace :cucumber do
    Cucumber::Rake::Task.new({:functional => 'db:test:prepare'}, 'Run only all functional test') do |t|
      t.cucumber_opts = "--tags ~@performance"
      t.profile = 'default'
    end
  end

rescue LoadError
  # cucumber not available in production env
end
