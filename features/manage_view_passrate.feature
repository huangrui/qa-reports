Feature: Passrate between builds
  This feature is the comparison both on test result and pass percentage with the different build id.

  Background:
    Given I am logged in
    Given I have created the "1.1/Core/Sanity/FeaturePassRate" report using "sim.xml" and optional build id is "1.2.0.90.0.20050517.1"
    And I have created the "1.1/Core/Sanity/FeaturePassRate" report using "sim_new.xml" and optional build id is "1.2.0.90.0.20050518.1"

  @smoke
  Scenario: Viewing the feature persentage for the different build
    When I view the report "1.1/Core/Sanity/FeaturePassRate" for build
    And I follow "See build pass%"
    Then I should see "*1.2.0.90.0.20050518.1"
    And I should see "1.2.0.90.0.20050517.1"
    And I should see "82%"
    And I should see "81%"
