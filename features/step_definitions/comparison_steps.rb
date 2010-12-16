When /^I am watching a report between branches "([^"]*)" and "([^"]*)"$/ do |branch1, branch2|
  Given %{I have one user "John Restless" with email "resting@man.net" and password "secretpass" and token "foobar"}
  When %{the client sends reports "spec/fixtures/sim1.xml,features/resources/bluetooth.xml" via the REST API to profile "#{branch1}" and hardware "N900"}
  When %{the client sends reports "spec/fixtures/sim1.xml,features/resources/bluetooth.xml" via the REST API to profile "#{branch1}" and hardware "N910"}
  When %{the client sends reports "spec/fixtures/sim1.xml,features/resources/bluetooth.xml" via the REST API to profile "#{branch2}" and hardware "N900"}
  When %{the client sends reports "spec/fixtures/sim2.xml,features/resources/bluetooth.xml" via the REST API to profile "#{branch2}" and hardware "N910"}
  And %{I should be able to compare between branches "#{branch1}" and "#{branch2}"}
end

When /^I should be able to compare between branches "([^"]*)" and "([^"]*)"$/ do |branch1, branch2|
  visit("/1.2/Core/#{branch1}/compare/#{branch2}")
end

Then /^I should see values "([^"]*)" in columns of "([^"]*)"$/ do |columns, scope|
  columns.split(",").each_with_index{|column, index|
      And %{I should see "#{column}" within "#{scope}.column_#{index}"}
  }

end


