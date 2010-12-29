Feature: REST API
  As an external service
  I want to upload reports via REST API
  So that they can be browsed by users

  Background:
    Given I am an user with a REST authentication token

  Scenario: Uploading test report with HTTP POST
    When the client sends file "sim.xml" via the REST API

    Then the REST result "ok" is "1"
    And I should be able to view the created report
    And I should see "src" within ".dl_link"

  Scenario: Uploading test report with HTTP POST with RESTful parameters
    When the client sends file "bluetooth.xml" via the REST API with RESTful parameters

    Then the REST result "ok" is "1"
    And I should be able to view the created report

  Scenario: Uploading test report with multiple files and attachments
    When the client sends file with attachments via the REST API
    Then the REST result "ok" is "1"
    And I should be able to view the created report

    Then I should see "SIM" within ".feature_name"
    And I should see "BT" within ".feature_name"

    And I should see "ajax-loader.gif" within "#file_attachment_list"
    And I should see "icon_alert.gif" within "#file_attachment_list"

  Scenario: Adding a report with tests that do not belong to any feature
    When the client sends reports "spec/fixtures/no_features.xml" via the REST API to test type "Automated" and hardware "N900"
    And I should be able to view the created report

    Then I should see "N/A" within ".feature_name"
    And I should see "8" within "td.total"
    
  Scenario: Sending REST import with string values instead of files
    When the client sends a request with string value instead of a files via the REST API

    Then the REST result "ok" is "0"
    Then the REST result "errors" is "Request contained invalid files: Invalid file attachment for field report.1"

  Scenario: Sending REST import without valid report file
    When the client sends a request without file via the REST API

    Then the REST result "ok" is "0"
    Then the REST result "errors|uploaded_files" is "can't be blank"

  Scenario: Sending REST import without valid parameters
    When the client sends a request without parameter "target" via the REST API

    Then the REST result "ok" is "0"
    Then the REST result "errors|target" is "can't be blank"


  Scenario: Sending REST import with invalid extra parameters
    When the client sends a request with extra parameter "foobar=1" via the REST API

    Then the REST result "ok" is "0"
    Then the REST result "errors" is "unknown attribute: foobar"