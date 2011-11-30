When %r/^report files "([^"]*)" are uploaded to branch "([^"]*)" for product "([^"]*)"$/ do |files, branch, hardware|
  Given "I am a user with a REST authentication token"
  When %{the client sends reports "#{files}" via the REST API to test set "#{branch}" and product "#{hardware}"}
end

Then %r/^I should see values "([^"]*)" in columns of "([^"]*)"$/ do |columns, scope|
  columns.split(",").each_with_index{|column, index|
      And %{I should see "#{column}" within "#{scope}.column_#{index}"}
  }
end

Then %r/^I should not see values "([^"]*)" in columns of "([^"]*)"$/ do |columns, scope|
  columns.split(",").each_with_index{|column, index|
      And %{I should not see "#{column}" within "#{scope}.column_#{index}"}
  }
end


