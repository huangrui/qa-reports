# Run with bundle exec watchr specs.watchr and enjoy BDD with continuous testing:

watch( 'spec/(.*)_spec\.rb' )  {|md| system("bundle exec rspec #{md[0]}") }
watch( 'lib/(.*)\.rb' )      {|md| system("bundle exec rspec spec/#{md[1]}_spec.rb") }
watch( 'app/(.*)\.rb' )      {|md| system("bundle exec rspec spec/#{md[1]}_spec.rb") }

# --------------------------------------------------
# Signal Handling
# --------------------------------------------------

# Ctrl-C
Signal.trap('INT') do
  if @interrupt_received
    exit 0
  else
    @interrupt_received = true
    puts "\nInterrupt a second time to quit"
    Kernel.sleep 1
    @interrupt_received = false
    puts "Running all tests..."
    system("bundle exec rspec spec/")
  end
end