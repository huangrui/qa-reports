Feature: automatically calculating the pass percentage for each features.
         and show the pass percentage in the feature summary of the report page.

  Background:
    Given I am a new, authenticated user
    And I have created the "1.1/Core/Sanity/FeaturePassRate" report using "sim.xml"
    And I have created the "1.1/Core/Sanity/FeaturePassRate" report using "sim_new.xml" at "2010-02-01"
    When I view the report "1.1/Core/Sanity/FeaturePassRate"

  @smoke
  Scenario: Viewing the feature persentage
    Then I should see "Pass%" within "#test_results_by_feature th.th_pass_rate"
    And I should see "81%" within "#test_results_by_feature td.rate"

  @smoke
  Scenario: Viewing the feature pass_rate history
    When I follow "See pass% history"
    Then I should see "01/02"
    And I should see "82%"
    And I should see "81%"

