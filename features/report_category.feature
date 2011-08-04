Feature: View several reports under a category

  Background:
    Given 5 reports exist from "2011/1" under "1.2/Core/automated/N900"
    And 5 reports exist from "2011/3" under "1.2/Core/automated/N900"

  @selenium
  Scenario: Viewing list of reports by month
    When I view the report category "1.2/Core/automated/N900"
    Then reports from "2011/1" should be in the report list under "January 2011"
    And reports from "2011/3" should be in the report list under "March 2011"