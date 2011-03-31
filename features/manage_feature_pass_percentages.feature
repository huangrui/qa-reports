Feature: automatically calculating the pass percentage for each features.
         and show the pass percentage in the feature summary of the report page.

  Background:
    Given I am a new, authenticated user
    And I have created the "1.1/Core/Sanity/FeaturePassRate" report using "sim.xml"
    When I view the report "1.1/Core/Sanity/FeaturePassRate"

  @smoke
  Scenario: Viewing the feature persentage
    Then I should see "Pass_Rate" within "#test_results"
    And I should see "81%" 
