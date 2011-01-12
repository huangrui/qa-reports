Feature: Edit Report

  Background:
    Given I am a new, authenticated user
    #And I have created the "1.1/Core/Sanity/Aava" report using "sim.xml"
    And I am on the front page
    And I follow "Add report"
    And I fill in "report_test_execution_date" with "2010-02-02"
    And I choose "1.1"
    And I select target "Core", test type "Sanity" and hardware "Aava"
    And I attach the report "sim.xml"
    And I submit the form at "upload_report_submit"
    #Then show me the page

    Then I should see "finalize the report"

    When I submit the form at "upload_report_submit"
    #Then show me the page

    When I view the report "1.1/Core/Sanity/Aava"
    #Then show me the page
    When I click to edit the report

  @selenium
  Scenario: Edit title
    When I click the element "h1"
    And fill in "meego_test_session[title]" with "Test title" within "h1"
    And I press "Save"
    Then I should see "Test title" within "h1"
