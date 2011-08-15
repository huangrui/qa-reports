Given /^I am not logged in$/ do
  visit destroy_user_session_path
end

Given /^I am viewing a test report$/ do
  FactoryGirl.create(:test_report)
  visit('/1.3/Hanset/Acceptance/N900/' + MeegoTestSession.first.id.to_s)
end

When /^I log in with valid credentials$/ do
  user = FactoryGirl.create(:user, 
    :name                  => 'Johnny Depp',
    :email                 => 'john@meego.com', 
    :password              => 'buzzword', 
    :password_confirmation => 'buzzword')

  click_link_or_button  'Sign In'
  fill_in               'Email',    :with => 'john@meego.com'
  fill_in               'Password', :with => 'buzzword'
  click_link_or_button  'Login'
end

Then /^I should be redirected back to the report I was viewing$/ do
  current_path.should == '/1.3/Hanset/Acceptance/N900/' + MeegoTestSession.first.id.to_s
end

Then /^I should see my username and "([^"]*)" button$/ do |arg1|
  page.should have_content('Johnny Depp')
  page.should have_link('Sign out')
end

When /^I log in with incorrect email$/ do
  click_link_or_button 'Sign In'

  fill_in              'Email',    :with => 'foobar@meego.com'
  fill_in              'Password', :with => 'buzzword'
  click_link_or_button 'Login'
end

When /^I log in with incorrect password$/ do
  click_link_or_button 'Sign In'

  fill_in              'Email',    :with => 'john@meego.com'
  fill_in              'Password', :with => 'iforgotit'
  click_link_or_button 'Login'
end

Given /^I am logged in$/ do
  visit '/'
  When "I log in with valid credentials"
end

When /^I log out$/ do
    click_link_or_button 'Sign out'
end

Given /^I am at the registration page$/ do
  visit new_user_registration_path
end

When /^I sign up with unique email address$/ do
  fill_in              'Full name',             :with => 'Johnny Depp'
  fill_in              'Email',                 :with => 'john@meego.com'
  fill_in              'Password',              :with => 'buzzword'
  fill_in              'Password confirmation', :with => 'buzzword'
  click_link_or_button 'Sign up'
end

When /^I sign up with an already registered email address$/ do
  When "I sign up with unique email address"
  When "I log out"
  Given "I am at the registration page"
  When "I sign up with unique email address"
end

When /^I sign up with invalid name, email and password$/ do
  fill_in              'Full name',             :with => ''
  fill_in              'Email',                 :with => 'peter@mee@go.com'
  fill_in              'Password',              :with => 'neverneverland'
  fill_in              'Password confirmation', :with => 'alwaysland'
  click_link_or_button 'Sign up'
end
