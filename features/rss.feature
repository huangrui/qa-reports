Feature: RSS Feed

  Background:
    Given I am a new, authenticated user
    And I have created the "1.1/Core/Sanity/Aava" report using "sim.xml"
    And I have created the "1.1/Core/Sanity/N900" report using "sim.xml"
    And I have created the "1.1/Core/Weekly/Aava" report using "sim.xml"
    And I have created the "1.1/Handset/Sanity/Aava" report using "sim.xml"
    And I have created the "1.1/Handset/Sanity/N900" report using "sim.xml"
    And I have created the "1.1/Handset/Weekly/Aava" report using "sim.xml"

  Scenario: Fetch RSS feed for leaf level filter
    When I fetch the rss feed for "1.1/Core/Sanity/Aava"
    Then I should see 1 instance of "item"

  Scenario: Fetch RSS feed for test type level filter
    When I fetch the rss feed for "1.1/Core/Sanity"
    Then I should see 2 instances of "item"
    And I should see "Aava"
    And I should see "N900"

  Scenario: Fetch RSS feed for target level filter
    When I fetch the rss feed for "1.1/Core"
    Then I should see 3 instances of "item"
    And I should see "Aava"
    And I should see "N900"
    And I should see "Sanity"
    And I should see "Weekly"

  Scenario: Fetch RSS feed for all reports in specific version
    When I fetch the rss feed for "1.1"
    Then I should see 6 instances of "item"
    And I should see "Core"
    And I should see "Handset"
