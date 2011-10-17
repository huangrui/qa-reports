Feature: Merge API
  In order to provide a REST API for merging the result of test cases from a specific report.
  The API respond at /api/merge/<report_id>
  When this API is invoked, the new uploaded result files(XML or CSV) would be parsed and merged with the existing results.

  Background:
    Given I am an user with a REST authentication token

  @wip
  Scenario: Merge a new testcase
    Given I have a report with
      | feature_name  | testcase_name | result |
      | featureA      | testcaseA     | Pass   |
    When I merge with
      | feature_name  | testcase_name | result |
      | featureA      | testcaseB     | Pass   |
    Then the API responds ok

    When I view the report
    Then I should see it contain
      | feature_name  | testcase_name | result |
      | featureA      | testcaseA     | Pass   |
      | featureA      | testcaseB     | Pass   |

  Scenario: Merge changed testcase
    Given I have a report with
      | feature_name  | testcase_name | result |
      | featureA      | testcaseA     | Pass   |
    When I merge with
      | feature_name  | testcase_name | result |
      | featureA      | testcaseA     | Fail   |
    Then the API responds ok

    When I view the report
    Then I should see it contain
      | feature_name  | testcase_name | result |
      | featureA      | testcaseA     | Fail   |

  Scenario: Merge changed testcase and a new one
    Given I have a report with
      | feature_name  | testcase_name | result |
      | featureA      | testcaseA     | Pass   |
    When I merge with
      | feature_name  | testcase_name | result |
      | featureA      | testcaseA     | Fail   |
      | featureA      | testcaseB     | Pass   |
    Then the API responds ok

    When I view the report
    Then I should see it contain
      | feature_name  | testcase_name | result |
      | featureA      | testcaseA     | Fail   |
      | featureA      | testcaseB     | Pass   |

  Scenario: Merge a new testcase and a feature
    Given I have a report with
      | feature_name  | testcase_name | result |
      | featureA      | testcaseA     | Pass   |
    When I merge with
      | feature_name  | testcase_name | result |
      | featureB      | testcaseA     | Fail   |
    Then the API responds ok

    When I view the report
    Then I should see it contain
      | feature_name  | testcase_name | result |
      | featureA      | testcaseA     | Fail   |
      | featureB      | testcaseA     | Fail   |

  Scenario: Merge changed testcases to a report with multiple test cases and features
    Given I have a report with
      | feature_name  | testcase_name | result |
      | featureA      | testcaseA     | Pass   |
      | featureA      | testcaseB     | Fail   |
      | featureB      | testcaseB     | Pass   |
    When I merge with
      | feature_name  | testcase_name | result |
      | featureA      | testcaseB     | Pass   |
      | featureB      | testcaseC     | Fail   |
    Then the API responds ok

    When I view the report
    Then I should see it contain
      | feature_name  | testcase_name | result |
      | featureA      | testcaseA     | Pass   |
      | featureA      | testcaseB     | Pass   |
      | featureB      | testcaseB     | Pass   |
      | featureB      | testcaseC     | Fail   |
