Feature: Check NFT graphs from the web page
  As a user
  I want to see graphical representation of NFT data
  So I can see how things have progressed over time

  Background:
    Given I am a new, authenticated user

    When I follow "Add report"
    And I select target "Handset", test set "NFT" and product "N900" with date "2010-11-21"
    And I attach the report "serial_result_2.xml"
    And submit the form at "upload_report_submit"
    And I press "Publish"

    And I follow "Add report"
    And I select target "Handset", test set "NFT" and product "N900" with date "2010-11-22"
    And I attach the report "serial_result.xml"
    And submit the form at "upload_report_submit"
    And I press "Publish"

  Scenario: Should see CSV data in view mode
    When I view the report "1.2/Handset/NFT/N900"
    Then I should see "Date,kg"

  Scenario: Should see serial measurement CSV data in view mode
    When I view the report "1.2/Handset/NFT/N900"
    Then I should see "Date,Max mA,Avg mA,Med mA,Min mA"

  Scenario: Should see "See history" link
    When I view the report "1.2/Handset/NFT/N900"
    Then I should see "See history"

  Scenario: Should not see CSV data in edit mode
    When I view the report "1.2/Handset/NFT/N900"
    And I follow "Edit"
    Then I should not see "Date,kg"
 
  Scenario: Should see serial history CSV data
    When I view the report "1.2/Handset/NFT/N900"
    Then I should see "2010-11-21,92.2,80.4909,84.4,30.0"
    And I should see "2010-11-22,500.0,486.855,486.8,478.4"

  # Note: the Selenium cases below are based on the JavaScript code updating
  # the title of the hidden modal windows - if we click an item and it works
  # at least to some extent, the title is changed. When these tests pass it
  # does not mean that the graph functionality works since the actual graph
  # may be broken.
  @selenium
  Scenario: Open and close NFT trend window
    When I view the report "1.2/Handset/NFT/N900"

    And I click on element "//a[@class='nft_trend_button'][1]"
    Then I should see "simple-case2: temperature" within "#nft_trend_dialog"

    And I click on element "//a[@class='ui_btn modal_close']"

  @selenium
  Scenario: Open and close NFT trend window in history view
    When I view the report "1.2/Handset/NFT/N900"
    
    And I follow "See history"

    And I click on element "//canvas[@id='nft-history-graph-2']"
    Then I should see "simple-case2: bandwidth" within "#nft_trend_dialog"

    And I click on element "//a[@class='ui_btn modal_close']"

  @selenium
  Scenario: Open and close NFT serial trend window in history view
    When I view the report "1.2/Handset/NFT/N900"
   
    And I follow "See history"

    And I click on element "//canvas[@id='serial-history-graph-4']"
    Then I should see "simple-case3: temperature" within "#nft_series_history_dialog"

    And I click on element "//a[@class='ui_btn modal_close']"
