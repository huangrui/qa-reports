Feature: automatically calculating the pass percentage for each features.
         and show the pass percentage in the feature summary of the report page.

  Background:
    Given I am a new, authenticated user
    And I have created the "1.1/Core/Sanity/FeaturePassRate" report using "sim.xml" and optional build id is "1.2.0.90.0.20110517.1"
    And I have created the "1.1/Core/System/FeaturePassRate_new" report using "sim_new.xml" and optional build id is "1.2.0.90.0.20110517.1"
    When I view the report "1.1/Core/Sanity/FeaturePassRate"

  @smoke
  Scenario: Viewing the feature persentage
    Then I should see "Pass%" within "#test_results_by_feature th.th_pass_rate"
    And I should see "81%" within "#test_results_by_feature td.rate"

  @smoke
  Scenario: Viewing the fature persentage for the same build
    When I view the report "1.1/Core/System/FeaturePassRate_new"
    And I follow "See the same build"
    Then I should see "*System/FeaturePassRate_new"
    Then I should see "Sanity/FeaturePassRate"
    And I should see "81%"
    And I should see "82%"

