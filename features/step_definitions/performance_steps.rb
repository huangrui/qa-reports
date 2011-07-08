Given /^I measure the speed of the test hardware$/ do
  t = Time.now
  5000000.times {|i| i=i }
  @slowness_factor = Time.now - t
  puts "Measured slowness factor of #{@slowness_factor} for this test machine."
end

When /^I start the timer$/ do
  @previous_step_time = @test_begin_time = Time.now
end

Then /^the time spent for the "([^\"]*)" step should be less than (\d+) seconds$/ do |step_name, max_seconds|
  completion_time = Time.now
  max_seconds = @slowness_factor * max_seconds.to_f

  puts %{Step "#{step_name}" completed in #{(completion_time - @previous_step_time).to_s}s, #{max_seconds}s was allowed}
  (completion_time - @previous_step_time).should < max_seconds

  @previous_step_time = Time.now
end

Then /^the total time spent since the start should be less than (\d+) seconds$/ do |max_seconds|
  completion_time = Time.now
  max_seconds = @slowness_factor * max_seconds.to_f

  puts %{Steps completed in #{(completion_time - @test_begin_time).to_s}s, #{max_seconds}s was allowed}
  (completion_time - @test_begin_time).should < max_seconds

  @previous_step_time = Time.now
end