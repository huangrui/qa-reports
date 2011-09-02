Feature: Build details
  This feature is the comparison both on test result and pass percentage with the different build id.

  Background:
    Given I am logged in
    Given I have created the "1.1/Core/Sanity/Aava" report and optional build id is "1.2.0.90.0.20050517.1"
    And I have created the "1.1/Core/Sanity/Aava" report using "sample_new.csv" and optional build id is "1.2.0.90.0.20050518.1"


  @javascript
  Scenario: Viewing the different build report
    When I view the report "1.1/Core/Sanity/Aava" for build
    And want to see build details
    Then I should see "*1.2.0.90.0.20050518.1"
    And I should see "1.2.0.90.0.20050517.1"
    Then "Check home screen theme and layout" should have results "Fail" and "Pass"
