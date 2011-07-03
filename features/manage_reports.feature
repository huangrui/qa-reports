Feature: Manage reports

  Background:
    Given I am a new, authenticated user
    And I have created the "1.1/Core/Sanity/Aava" report and optional build id is "1.2.0.90.0.20050517.1"
    And I have created the "1.1/Core/System/Eeepc" report using "sample_new.csv" and optional build id is "1.2.0.90.0.20050517.1"
    When I view the report "1.1/Core/Sanity/Aava"

  @smoke
  Scenario: Viewing a report
    Then I should see "MeeGo" within "#version_navi"
    And I should see the header

    And I should see "Check home screen"
    And I should see "Fail"
    And I should see "3921"

  @smoke
  Scenario: Viewing the same build report
    When I view the report "1.1/Core/System/Eeepc"
    And I follow "See the same build"
    Then I should see "* System"
    And I should see "* Eeepc"
    And I should see "Sanity"
    And I should see "Aava"
    And I should see "Check home screen"
    And I should see "Fail"
    And I should see "Pass"

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
    When I view the report "1.1/Core/Sanity/Aava"
    And I click to delete the report

    Then I should see "Are you sure you want to delete"

  Scenario: Linking from print view to report view
    When I click to print the report

    Then I should see "Click here to view this message in your browser or handheld device" within ".report-backlink"
    And the link "Click here" within ".report-backlink" should point to the report "1.1/Core/Sanity/Aava"
