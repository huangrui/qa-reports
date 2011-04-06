Feature: REST API update report with nft
  As an external service
  I want to update reports via REST API
  So that they can be browsed by users

  When this API is invoked, the new uploaded result files(XML or CSV) would be parsed and saved in DB, and the original test cases should be removed.
  
  Background:
    Given I am an user with a REST authentication token
    And I have sent the file "serial_result.xml" via the REST API

  Scenario: Updating test report with HTTP POST with nft cases removed from the report
    When the client sends a updated file "sim.xml" with the id 1 via the REST API

    Then the REST result "ok" is "1"
    
    When I view the report "1.2/Netbook/Automated/N900"
    Then I should not find element "#detailed_nft_results"
    And I should not find element "a[href='#detailed_nft_results']" within ".toc"
