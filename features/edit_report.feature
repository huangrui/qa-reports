Feature: Edit Report

  Background:
    Given the report for "short-sim.csv" exists on the service
    And I am logged in

  @javascript
  Scenario: Add and view a test case attachment for existing report
    When I edit the report "1.2/Core/automated/N900"

    When I click the element ".testcase_notes" for the test case "SMOKE-SIM-Get_IMSI"
    And I attach the file "attachment.txt" to test case "SMOKE-SIM-Get_IMSI"
    And I wait until all Ajax requests are complete

    When I click the element ".testcase_notes" for the test case "SMOKE-SIM-Get_IMSI"
    And I click the element ".attachment_link" for the test case "SMOKE-SIM-Get_IMSI"

    Then I should see "Content of the attachment file"

  @javascript
  Scenario: Add and remove a test case attachment from existing report
    When I edit the report "1.2/Core/automated/N900"

    When I click the element ".testcase_notes" for the test case "SMOKE-SIM-Get_IMSI"
    And I attach the file "short1.csv" to test case "SMOKE-SIM-Get_IMSI"
    And I wait until all Ajax requests are complete

    Then I click the element ".testcase_notes" for the test case "SMOKE-SIM-Get_IMSI"
    And I should see "short1.csv"

    When I remove the attachment from the test case "SMOKE-SIM-Get_IMSI"
    And I wait until all Ajax requests are complete

    When I click the element ".testcase_notes" for the test case "SMOKE-SIM-Get_IMSI"
    Then I should not see "short1.csv"

  @javascript
  Scenario: Edit title
    When I edit the report "1.2/Core/automated/N900"
    And I click the element "h1"
    And fill in "report[title]" with "Test title" within "h1"
    And I press "Save"
    And I wait until all Ajax requests are complete

    Then I should see "Test title" within "h1"

  @javascript
  Scenario: Edit test execution date
    When I view the report "1.2/Core/automated/N900"
    And I click to edit the report
    And I click the element ".editable_date"
    And fill in "Test execution date:" with "2011-1-1"
    And I press "Save"

    Then I should see "01 January 2011" within "#test_category .date"

  @javascript
  Scenario: Edit test objective
    When I edit the report "1.2/Core/automated/N900"
    And I click the element "#test_objective"
    And fill in "report[objective_txt]" within ".editable_area" with:
      """
      == Test Header ==
      * testing list
      """
    And I press "Save"
    And I wait until all Ajax requests are complete

    Then I should see "testing list" within ".editable_area ul li"
    And I should see "Test Header" within ".editable_area h3"

  @javascript
  Scenario: Create a dynamic link to bugzilla
    When I edit the report "1.2/Core/automated/N900"
    And I click the element "#test_objective"
    And fill in "report[objective_txt]" with "* [[9353]]" within ".editable_area"
    And I press "Save"
    And I wait until all Ajax requests are complete

    Then I should see "[FEA] Automatic reporting interface to MeeGo QA reports" within ".editable_area ul li"

  @javascript
  Scenario: I delete a test case
    When I edit the report "1.2/Core/automated/N900"
    And I delete the test case "SMOKE-SIM-Get_IMSI"

    Then I return to view the report "1.2/Core/automated/N900"
    And there should not be a test case "SMOKE-SIM-Get_IMSI"

  @javascript
  Scenario: I delete all test cases
    When I edit the report "1.2/Core/automated/N900"
    And delete all test cases

    Then I return to view the report "1.2/Core/automated/N900"
    Then the report should not contain a detailed test results section

  @javascript
  Scenario: I modify a test case result
    When I edit the report "1.2/Core/automated/N900"
    And I change the test case result of "SMOKE-SIM-Get_IMSI" to "Pass"
    And I press "Done"
    And I follow "See all"

    Then the result of test case "SMOKE-SIM-Get_IMSI" should be "Pass"

  @javascript
  Scenario: I modify a test case comment
    When I edit the report "1.2/Core/automated/N900"
    And I change the test case comment of "SMOKE-SIM-Get_IMSI" to "edited comment"
    And I press "Save"
    And I press "Done"

    Then I should see "edited comment"

