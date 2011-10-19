Feature: Show only latest test sets and products on front page
  In order to reduce noice on the front page
  QA Managers
  Want that inactive test sets and products are hidden

  Background:
    Given there's a "1.2/Core/Acceptance/Pinetrail" report created "40" days ago
    And   there's a "1.2/Handset/Sanity/N900CE" report created "10" days ago
    And   there's a "1.1/Netbook/NFT/N9005" report created "10" days ago
    And   there's a "1.1/IVI/Functional/Pineapple" report created "60" days ago
    And   I am on the front page

  @javascript
  Scenario: Visiting home page
    Then only recent categories from release "1.2" should be shown

  @javascript
  Scenario: See all categories
    When I follow "All"
    Then all categories from release "1.2" should be shown

  @javascript
  Scenario: Select all and then recent
    When I follow "All"
    And  I follow "Recent"
    Then only recent categories from release "1.2" should be shown

  @javascript
  Scenario: Select all and change release
    When I follow "All"
    Then all categories from release "1.2" should be shown

    When  I follow "1.1"
    Then all categories from release "1.1" should be shown

  @javascript
  Scenario: Select all change release and select recent

  @javascript
  Scenario: Select release 1.2 and show all
