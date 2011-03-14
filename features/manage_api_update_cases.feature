Feature: Manage api_update_cases
  In order to provide a REST API for updating the result of test cases from a special report. 
  The API respond at /api/update/<report_id>
  When this API is invoked, the new uploaded result files(XML or CSV) would be parsed and saved in DB, and the original test cases should be removed. 
  
  Background:
    Given I am an user with a REST authentication token
    And I have sent the file "sim.xml" via the REST API

  Scenario: Updating test report with HTTP POST with valid result file
    When the client sends a updated file "sim_new.xml" with the id 1 via the REST API

    Then the REST result "ok" is "1"
    
    When I view the report "1.2/Netbook/Automated/N900"
    Then I should see "updated_case"

  Scenario: Updating test report with HTTP POST with an invalid result file
    When the client sends a updated file "invalid.xml" with the id 1 via the REST API
    Then the REST result "ok" is "0"
    When I view the report "1.2/Netbook/Automated/N900"
    Then I should not see "updated_case"
    And I should see "SIM"

  Scenario: Updating test report with HTTP POST with an invalid ext file
    When the client sends a updated file "invalid_ext.txt" with the id 1 via the REST API
    Then the REST result "ok" is "0"
    When I view the report "1.2/Netbook/Automated/N900"
    Then I should not see "updated_case"
    And I should see "SIM"

  Scenario: Updating test report with HTTP POST with multiple valid result file
    When the client sends several updated files with the id 1 via the REST API

    Then the REST result "ok" is "1"

    When I view the report "1.2/Netbook/Automated/N900"
    Then I should see "updated_case"

  Scenario: Updating test report with HTTP POST with multiple valid result file
    When the client sends 1 updated valid file, and 1 invalid file with the id 1 via the REST API

    Then the REST result "ok" is "0"

    When I view the report "1.2/Netbook/Automated/N900"
    Then I should not see "updated_case"
    And I should see "SIM"
