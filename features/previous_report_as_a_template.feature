Feature: Previous report as a template
  In order to decrease manual work
  As a test engineer
  I want to have the previous test report as a template (with same release, profile, test set and product)

  @javascript
  Scenario: Same test case results
    Given there's an existign report
    And   I create a new test report with same test cases
    Then  I should see the test case comments from the previous test report if the result hasn't changed