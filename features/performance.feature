Feature: Loading times
  As a service or real user
  I want every request to complete in a reasonable time

  Background:
    #Given I am an user with a REST authentication token

  Scenario: Uploading test report with HTTP POST
    Given I am a new, authenticated user

  
  
  Scenario: Uploading test report via the REST API
    Given I am an user with a REST authentication token

    When I start the timer
    And the client sends file "2000_cases.csv" via the REST API
    Then the total time spent since the start should be less than 10 seconds