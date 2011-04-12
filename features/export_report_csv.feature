Feature: As a Test Engineer I want to download existing reports as CSV files.

  Background:
    Given I am a new, authenticated user
    And I have created the "1.1/Core/Sanity/FeaturePassRate" report using "short1.csv"
    And I have created the "1.1/Core/Sanity/FeaturePassRate" report using "short2.csv"

  Scenario: Group report CSV merges several reports
    When I view the group report "1.1/Core/Sanity/FeaturePassRate"
    And I follow "Download as CSV"
    Then I should see in CSV the feature "Feature One" with case "Description One", note "OK" and result "1;0;0"
    And I should see in CSV the feature "Feature Two" with case "Description Two", note "This Fails" and result "0;1;0"
    And I should see in CSV the feature "Feature Three" with case "Description Three", note "OK" and result "1;0;0"
    And I should see in CSV the feature "Feature Four" with case "Description Four", note "This Fails" and result "0;1;0"