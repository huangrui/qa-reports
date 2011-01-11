Feature: Edit Report

  Background:
    Given I am a new, authenticated user
    And I have created the "1.1/Core/Sanity/Aava" report using "sim.xml"
    When I view the report "1.1/Core/Sanity/Aava"
    And I click to edit the report

  @javascript
  Scenario: Edit title
    When I click the element "h1"
    And fill in "meego_test_session[title]" with "Test title" within "h1"
    And I press "Save"
    Then I should see "Test title" within "h1"
