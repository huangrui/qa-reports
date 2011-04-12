Feature: As a Test Engineer I want to download existing reports as CSV files.

  Background:
    Given I am a new, authenticated user
    And I have created the "1.1/Core/Sanity/FeaturePassRate" report using "short1.csv"
    And I have created the "1.1/Core/Sanity/FeaturePassRate" report using "short2.csv"

  Scenario: Download group report CSV
    When I view the group report "1.1/Core/Sanity/FeaturePassRate"
    And I follow "Download as CSV"
    Then I should see the imported data from "short1.csv" and "short2.csv" in the exported CSV.