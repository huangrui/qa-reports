Feature: As a Test Engineer I want to export detail test cases from the existed report as a CSV file.

  Background:
    Given I am a new, authenticated user
    And I have created the "1.1/Core/Sanity/ExportTestCases" report using "short3.csv"

  Scenario: Download detail test cases as CSV from one report
    When I view the report "1.1/Core/Sanity/ExportTestCases"
    And I follow "Download as CSV"
    Then I should see the imported test cases from "short3.csv" in the exported CSV.
