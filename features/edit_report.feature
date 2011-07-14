Feature: Edit Report

  Background:
    Given I am a new, authenticated user
    And I have created the "1.1/Core/Sanity/Aava" report using "short-sim.csv"

  @selenium
  Scenario: Add and view a test case attachment for existing report
    When I view the report "1.1/Core/Sanity/Aava"
    And I click to edit the report

    When I click the element ".testcase_notes" for the test case "SMOKE-SIM-Get_IMSI"
    And I attach the file "attachment.txt" to test case "SMOKE-SIM-Get_IMSI"
    And I wait until all Ajax requests are complete

    When I click the element ".testcase_notes" for the test case "SMOKE-SIM-Get_IMSI"
    And I click the element "#attachment_link" for the test case "SMOKE-SIM-Get_IMSI"

    Then I should see "Content of the attachment file"

  @selenium
  Scenario: Add and remove a test case attachment from existing report
    When I view the report "1.1/Core/Sanity/Aava"
    And I click to edit the report

    When I click the element ".testcase_notes" for the test case "SMOKE-SIM-Get_IMSI"
    And I attach the file "short1.csv" to test case "SMOKE-SIM-Get_IMSI"
    And I wait until all Ajax requests are complete

    Then I click the element ".testcase_notes" for the test case "SMOKE-SIM-Get_IMSI"
    And I should see "short1.csv"

    When I remove the attachment from the test case "SMOKE-SIM-Get_IMSI"
    And I wait until all Ajax requests are complete

    When I click the element ".testcase_notes" for the test case "SMOKE-SIM-Get_IMSI"
    Then I should not see "short1.csv"

  @selenium
  Scenario: Edit title
    When I view the report "1.1/Core/Sanity/Aava"
    And I click to edit the report
    And I click the element "h1"
    And fill in "meego_test_session[title]" with "Test title" within "h1"
    And I press "Save"
    And I wait until all Ajax requests are complete

    Then I should see "Test title" within "h1"

#  XXX: Temporarily commented out. For some reason doesn't work via Selenium, but works when tested manually
#  @selenium
#  Scenario: Edit test execution date
#    When I view the report "1.1/Core/Sanity/Aava"
#    And I click to edit the report
#    And I click the element ".editable_date"
#    And fill in "meego_test_session[tested_at]" with "2011-1-1" within "#upload_report"
#    And I press "Save"
#
#    Then I should see "01 January 2011" within "#test_category .date"

  @selenium
  Scenario: Edit test objective
    When I view the report "1.1/Core/Sanity/Aava"
    And I click to edit the report
    And I click the element "#test_objective"
    And fill in "meego_test_session[objective_txt]" within ".editable_area" with:
      """
      == Test Header ==
      * testing list
      """
    And I press "Save"
    And I wait until all Ajax requests are complete

    Then I should see "testing list" within ".editable_area ul li"
    And I should see "Test Header" within ".editable_area h3"

  @selenium
  Scenario: Create a dynamic link to bugzilla
    When I view the report "1.1/Core/Sanity/Aava"
    And I click to edit the report
    And I click the element "#test_objective"
    And fill in "meego_test_session[objective_txt]" with "* [[9353]]" within ".editable_area"
    And I press "Save"
    And I wait until all Ajax requests are complete

    Then I should see "[FEA] Automatic reporting interface to MeeGo QA reports" within ".editable_area ul li"

  @selenium
  Scenario: I delete a test case
    When I edit the report "1.1/Core/Sanity/Aava"
    And I delete the test case "SMOKE-SIM-Get_IMSI"

    Then I return to view the report "1.1/Core/Sanity/Aava"
    And there should not be a test case "SMOKE-SIM-Get_IMSI"

  @selenium
   Scenario: I delete all test cases
     When I edit the report "1.1/Core/Sanity/Aava"
     And delete all test cases

     Then I return to view the report "1.1/Core/Sanity/Aava"
     Then the report should not contain a detailed test results section
