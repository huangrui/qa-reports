Feature: Manage api_update_cases
  In order to provide a REST API for updating the result of test cases from a special report. 
  The API respond at /api/update/<report_id>
  When this API is invoked, the new uploaded result files(XML or CSV) would be parsed and saved in DB, and the original test cases should be removed. 
  
  Background:
    Given I am an user with a REST authentication token

  Scenario: Updating test report with HTTP POST with valid result file
    When the client sends file "sim.xml" via the REST API

    Then the REST result "ok" is "1"

  Scenario: Updating test report with HTTP POST with an invalid result file
    When the client sends file "invalid.xml" via the REST API

    Then the REST result "ok" is "0"
