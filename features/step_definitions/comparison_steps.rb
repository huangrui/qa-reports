When /^report files "([^"]*)" are uploaded to branch "([^"]*)" for hardware "([^"]*)"$/ do |files, branch, hardware|
  Given %{I have one user "John Restless" with email "resting@man.net" and password "secretpass" and token "foobar"}
  When %{the client sends reports "#{files}" via the REST API to test set "#{branch}" and hardware "#{hardware}"}
end

Then /^I should see values "([^"]*)" in columns of "([^"]*)"$/ do |columns, scope|
  columns.split(",").each_with_index{|column, index|
      And %{I should see "#{column}" within "#{scope}.column_#{index}"}
  }
end


