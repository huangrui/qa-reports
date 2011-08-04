Feature: Filter visible test cases when viewing a report
  As a user
  I want to change the visibility of some test cases
  So I can more easily see the cases I am interested in

  Background:
    Given the report for "short4.csv" exists on the service
    And I view the report "1.2/Core/Automated/N900"

  @selenium
  Scenario: As a default, passed test cases are hidden
    Then I should not see "Test Two"
