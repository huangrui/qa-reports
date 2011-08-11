Feature: Manage reports

  Background:
    Given the report for "sample.csv" exists on the service
    And I am logged in
    When I view the report "1.2/Core/automated/N900"

  @smoke
  Scenario: Viewing a report
    Then I should see "MeeGo" within "#version_navi"
    And I should see the header

    And I should see "Check home screen"
    And I should see "Fail"
    And I should see "3921"

  @smoke
  Scenario: Printing a report
	When I click to print the report

    And I should not see the header

    And I should see "Check home screen"
    And I should see "Fail"
    And I should see "3921"

  @smoke
  Scenario: Editing a report
    When I click to edit the report

    Then I should see "Edit the report information" within ".notification"
    And I should see "Test Objective" within ".editable_text #test_objective"

  Scenario: Deleting a report
    When I view the report "1.2/Core/automated/N900"
    And I click to delete the report

    Then I should see "Are you sure you want to delete"

  Scenario: Linking from print view to report view
    When I click to print the report

    Then I should see "Click here to view this message in your browser or handheld device" within ".report-backlink"
    And the link "Click here" within ".report-backlink" should point to the report "1.2/Core/automated/N900"
