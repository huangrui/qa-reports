Feature: View several reports under a category

  Background:
    Given there are 5 reports from "2011/1" under "1.2/Core/automated/N900"
    And there are 5 reports from "2011/3" under "1.2/Core/automated/N900"

  @selenium
  Scenario: Viewing list of reports by month
    When I view the report category "1.2/Core/automated/N900"
    Then reports from "2011/1" should be in the report list under "January 2011"
    And reports from "2011/3" should be in the report list under "March 2011"

  @selenium
  Scenario: More reports are loaded as the page is scrolled down
    Given there are 50 reports from "2011/4" under "1.2/Core/automated/N900"
    And there are 5 reports from "2011/5" under "1.2/Core/automated/N900"

    When I view the report category "1.2/Core/automated/N900"
    Then reports for "May 2011" should not be visible on the page

    Then I scroll down the page
    And reports from "2011/5" should be in the report list under "May 2011"

  Scenario: View the graph for recent report history
