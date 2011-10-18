Feature: Merge API
  In order to provide a REST API for merging the result of test cases to a specific report.
  The API responds at /api/merge/<report_id>
  When this API is invoked, the new uploaded result files (XML or CSV) will be parsed and merged with the existing results.

  Background:
    Given I am a user with a REST authentication token
    And   I have created a test report

  # Valid cases

  Scenario: Merge with valid parameters
    When I merge with the latest report using result file "sample.csv"
    Then the API responds ok

  Scenario: Updating test report with multiple valid result files
    When I merge with the latest report using multiple files
    Then the API responds ok

  # Missing parameters

  Scenario: Try to merge without a result file
    When I merge with the latest report without defining a result file
    Then the API responds with an error about "missing result file"

  Scenario: Try to merge without an auth token
    When I merge with the latest report without defining an auth token
    Then the API responds with an error about "missing auth token"

  # Invalid parameters

  Scenario: Try to merge with a file which has invalid extension
    When I merge with the latest report using result file "invalid_ext.txt"
    Then the API responds with an error about "invalid file extension"

  Scenario: Try to merge with invalid result file
    When I merge with the latest report using result file "invalid.xml"
    Then the API responds with an error about "invalid result file"

  Scenario: Try to merge to a non-existing report
    When I merge with the latest report using result file "sample.csv"
    Then the API responds with an error about "report not found"

  Scenario: Updating test report with a valid and an invalid file
    When I merge with the latest report using multiple files including an invalid file
    Then the API responds with an error about "invalid result file"

#  @wip
#  Scenario: Merge a new testcase
#    Given I have a report with
#      | feature_name  | testcase_name | result |
#      | featureA      | testcaseA     | Pass   |
#    When I merge with
#      | feature_name  | testcase_name | result |
#      | featureA      | testcaseB     | Pass   |
#    Then the API responds ok
#
#    When I view the report
#    Then I should see it contain
#      | feature_name  | testcase_name | result |
#      | featureA      | testcaseA     | Pass   |
#      | featureA      | testcaseB     | Pass   |
#
#  Scenario: Merge changed testcase
#    Given I have a report with
#      | feature_name  | testcase_name | result |
#      | featureA      | testcaseA     | Pass   |
#    When I merge with
#      | feature_name  | testcase_name | result |
#      | featureA      | testcaseA     | Fail   |
#    Then the API responds ok
#
#    When I view the report
#    Then I should see it contain
#      | feature_name  | testcase_name | result |
#      | featureA      | testcaseA     | Fail   |
#
#  Scenario: Merge changed testcase and a new one
#    Given I have a report with
#      | feature_name  | testcase_name | result |
#      | featureA      | testcaseA     | Pass   |
#    When I merge with
#      | feature_name  | testcase_name | result |
#      | featureA      | testcaseA     | Fail   |
#      | featureA      | testcaseB     | Pass   |
#    Then the API responds ok
#
#    When I view the report
#    Then I should see it contain
#      | feature_name  | testcase_name | result |
#      | featureA      | testcaseA     | Fail   |
#      | featureA      | testcaseB     | Pass   |
#
#  Scenario: Merge a new testcase and a feature
#    Given I have a report with
#      | feature_name  | testcase_name | result |
#      | featureA      | testcaseA     | Pass   |
#    When I merge with
#      | feature_name  | testcase_name | result |
#      | featureB      | testcaseA     | Fail   |
#    Then the API responds ok
#
#    When I view the report
#    Then I should see it contain
#      | feature_name  | testcase_name | result |
#      | featureA      | testcaseA     | Fail   |
#      | featureB      | testcaseA     | Fail   |
#
#  Scenario: Merge changed testcases to a report with multiple test cases and features
#    Given I have a report with
#      | feature_name  | testcase_name | result |
#      | featureA      | testcaseA     | Pass   |
#      | featureA      | testcaseB     | Fail   |
#      | featureB      | testcaseB     | Pass   |
#    When I merge with
#      | feature_name  | testcase_name | result |
#      | featureA      | testcaseB     | Pass   |
#      | featureB      | testcaseC     | Fail   |
#    Then the API responds ok
#
#    When I view the report
#    Then I should see it contain
#      | feature_name  | testcase_name | result |
#      | featureA      | testcaseA     | Pass   |
#      | featureA      | testcaseB     | Pass   |
#      | featureB      | testcaseB     | Pass   |
#      | featureB      | testcaseC     | Fail   |

