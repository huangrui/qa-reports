Feature: Consolidated reports
  As a Release Manager
  I want to compare reports of different hardware versions between branches
  So that I can decide if it's safe to create new release

  Scenario: Comparing results between two branches
    When I am watching a report between branches "Sanity" and "SanityTesting"

    Then I should see "-2" within "#changed_to_fail"
    And I should see "+1" within "#changed_to_pass"

    And I should see values "N900,N910,N900,N910" in columns of "tr.compare_testtype th"

    And I should see "SMOKE-SIM-Disable_PIN_query" within "#row_2 .testcase_name"
    And I should see values "Fail,Fail,Fail,Pass" in columns of "#row_2 td"

    And I should see "SMOKE-SIM-Get_IMSI" within "#row_10 .testcase_name"
    And I should see values "Pass,Pass,Pass,Fail" in columns of "#row_10 td"



