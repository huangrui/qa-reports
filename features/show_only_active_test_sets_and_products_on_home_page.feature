Feature: Show only latest test sets and products on front page
  In order to reduce noice on the front page
  QA Managers
  Want that inactive test sets and products are hidden

  Background:
    Given there's a "Core/Acceptance/Pinetrail" report created "40" days ago
    And   there's a "Handset/Sanity/N900CE" report created "10" days ago
    And   I am on the front page

  @javascript
  Scenario: See only active categories
    Then I should see "Sanity"
    And  I should see "N900CE"
    And  I should not see "Acceptance"
    And  I should not see "Pinetrail"

  @javascript
  Scenario: See all categories
    When I follow "All"
    Then I should see "Sanity"
    And  I should see "N900CE"
    And  I should see "Acceptance"
    And  I should see "Pinetrail"