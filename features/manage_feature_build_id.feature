Feature: Manage feature build id
  This feature is the comparison both on test result and pass percentage with the different build id.

  Background:
    Given I am a new, authenticated user
    Given I have created the "1.1/Core/Sanity/FeaturePassRate" report using "sim.xml" and optional build id is "1.2.0.90.0.20050517.1"
    And I have created the "1.1/Core/Sanity/FeaturePassRate" report using "sim_new.xml" and optional build id is "1.2.0.90.0.20050518.1"
    Given I have created the "1.1/Core/Sanity/Aava" report and optional build id is "1.2.0.90.0.20050517.1"
    And I have created the "1.1/Core/Sanity/Aava" report using "sample_new.csv" and optional build id is "1.2.0.90.0.20050518.1"

  @smoke
  Scenario: Viewing the feature persentage for the different build
    When I view the report "1.1/Core/Sanity/FeaturePassRate" for build
    And I follow "See build pass%"
    Then I should see "*1.2.0.90.0.20050518.1"
    And I should see "1.2.0.90.0.20050517.1"
    And I should see "82%"
    And I should see "81%"
    
  @smoke
  Scenario: Viewing the different build report
    When I view the report "1.1/Core/Sanity/Aava" for build
    And I follow "See build"
    Then I should see "*1.2.0.90.0.20050518.1"
    And I should see "1.2.0.90.0.20050517.1"
    And I should see "Check home screen"
    And I should see "Fail"
    And I should see "Pass"

