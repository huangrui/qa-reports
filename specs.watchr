# Run with bundle exec watchr specs.watchr and enjoy BDD with continuous testing:

watch( 'spec/(.*)\.rb' ) {|md| system("rspec #{md}") if File.exists?(md)}
watch( 'lib/(.*)\.rb' )  {|md| system("rspec spec/lib/#{md[1]}_spec.rb") if File.exists?("spec/lib/#{md[1]}_spec.rb") }
watch( 'app/(.*)\.rb' )  {|md| system("rspec spec/#{md[1]}_spec.rb") if File.exists?("spec/#{md[1]}_spec.rb") }

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
    system("rspec spec/")
  end
end