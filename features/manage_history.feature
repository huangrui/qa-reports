Feature: Test result history
  The history report will be clearer, if the the comment of the test cases result could be shown in the "see history"

  Background:
    Given I am logged in
    And I have created the "1.1/Core/Sanity/Aava" report using "sample.csv"
    And I have created the "1.1/Core/Sanity/Aava" report with date "2010-02-03" using "sample_new.csv"

  @javascript
  Scenario: Viewing the test results history and latest comment
    When I view the report "1.1/Core/Sanity/Aava"
    And click to see test results history

    Then I should see "3921"
