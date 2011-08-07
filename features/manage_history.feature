Feature: Manage history
  The history report will be clearer, if the the comment of the test cases result could be shown in the "see history"

  Background:
    Given I am a new, authenticated user
    Given I have created the "1.1/Core/Sanity/Aava" report using "sample.csv"
    And I have created the "1.1/Core/Sanity/Aava" report with date "2010-02-03" using "sample_new.csv"


  @selenium
  Scenario: Viewing the different build report
    When I view the report "1.1/Core/Sanity/Aava"
    And want to see history details
    Then I should see "3921"
