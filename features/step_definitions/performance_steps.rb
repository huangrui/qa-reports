When /^I start the timer$/ do
  @test_begin_time = Time.now
  @previous_step_time = @total_time_timer
end

Then /^the time spent since the latest check point should be less than (\d+) seconds$/ do |max_seconds|
  (Time.now - @previous_step_time).should < max_seconds.to_f
  @previous_step_time = Time.now
end

Then /^the total time spent since the start should be less than (\d+) seconds$/ do |max_seconds|
  (Time.now - @test_begin_time).should < max_seconds.to_f
end