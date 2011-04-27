# Run with bundle exec watchr specs.watchr and enjoy BDD with continuous testing:

watch( 'spec/(.*)_spec\.rb' )  {|md| system("bundle exec rspec #{md[0]}") }
watch( 'lib/(.*)\.rb' )      {|md| system("bundle exec rspec spec/#{md[1]}_spec.rb") }
watch( 'app/(.*)\.rb' )      {|md| system("bundle exec rspec spec/#{md[1]}_spec.rb") }