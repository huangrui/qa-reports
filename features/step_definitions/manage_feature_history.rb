And /^want to see history details$/ do
  find(:xpath, "//a[@id='detailed_case' and @class = 'see_history_button sort_btn']").click
end
