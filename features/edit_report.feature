Feature: Edit Report

  Background:
    Given I am a new, authenticated user
    And I have created the "1.1/Core/Sanity/Aava" report using "sim.xml"

  @selenium
  Scenario: Edit title
    When I view the report "1.1/Core/Sanity/Aava"
    And I click to edit the report
    And I click the element "h1"
    And fill in "meego_test_session[title]" with "Test title" within "h1"
    And I press "Save"

    Then I should see "Test title" within "h1"

  @selenium
  Scenario: Edit test execution date
    When I view the report "1.1/Core/Sanity/Aava"
    And I click to edit the report
    And I click the element ".editable_date"
    And fill in "meego_test_session[tested_at]" with "2011-1-1" within ".editable_date"
    And I press "Save"

    Then I should see "1 January 2011" within ".editable_date"

  @selenium
  Scenario: Edit test objective
    When I view the report "1.1/Core/Sanity/Aava"
    And I click to edit the report
    And I click the element "#test_objective"
    And fill in "meego_test_session[objective_txt]" with "* testing" within ".editable_area"
    And I press "Save"

    Then I should see "testing" within ".editable_area ul li"

  @selenium
  Scenario: Create a dynamic link to bugzilla
    When I view the report "1.1/Core/Sanity/Aava"
    And I click to edit the report
    And I click the element "#test_objective"
    And fill in "meego_test_session[objective_txt]" with "* [[9353]]" within ".editable_area"
    And I press "Save"

    Then I should see "[FEA] Automatic reporting interface to MeeGo QA reports" within ".editable_area ul li"

