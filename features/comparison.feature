Feature: Consolidated reports
  As a Release Manager
  I want to compare reports of different hardware versions between branches
  So that I can decide if it's safe to create new release

  Scenario: Comparing results between two branches with differences
    When report files "spec/fixtures/sim1.xml,features/resources/bluetooth.xml" are uploaded to branch "Sanity" for hardware "N900"
    And report files "spec/fixtures/sim1.xml,features/resources/bluetooth.xml" are uploaded to branch "Sanity" for hardware "N910"
    And report files "spec/fixtures/sim1.xml,features/resources/bluetooth.xml" are uploaded to branch "Sanity:Testing" for hardware "N900"
    And report files "spec/fixtures/sim2.xml,features/resources/bluetooth.xml" are uploaded to branch "Sanity:Testing" for hardware "N910"

    When I am on the front page
    And I follow "compare"

    Then I should see "1" within "#changed_to_pass"
    And I should see "2" within "#changed_from_pass"
    And I should see "1" within ".changed_from_fail"
    And I should see "0" within ".changed_from_na"
    And I should see "2" within ".fail.changed_from_pass"
    And I should see "0" within ".na.changed_from_pass"


    And I should see "0" within "#new_passing"
    And I should see "1" within "#new_failing"
    And I should see "0" within "#new_na"

    And I should see values "N900,N910,N900,N910" in columns of "tr.compare_testtype th"

    And I should see "SMOKE-SIM-Disable_PIN_query" within "#test_case_14 .testcase_name"
    And I should see values "Fail,Fail,Fail,Pass" in columns of "#test_case_14 td"

    And I should see "SMOKE-SIM-Get_IMSI" within "#test_case_1 .testcase_name"
    And I should see values "Pass,Pass,Pass,Fail" in columns of "#test_case_1 td"


#  Scenario: Comparing results between two branches where data is missing for one device
#    When report files "spec/fixtures/sim1.xml,features/resources/bluetooth.xml" are uploaded to branch "Sanity" for hardware "N900"
#    And report files "spec/fixtures/sim1.xml,features/resources/bluetooth.xml" are uploaded to branch "Sanity" for hardware "N910"
#    And report files "spec/fixtures/sim2.xml,features/resources/bluetooth.xml" are uploaded to branch "Sanity:Testing" for hardware "N910"

#    When I am on the front page
#    And I follow "compare"

#    And I should see "+1" within "#changed_to_pass"
#    Then I should see "-2" within "#changed_to_fail"

#    And I should see values "N900,N910,N900,N910" in columns of "tr.compare_testtype th"

#    And I should see "SMOKE-SIM-Update_ADN_phonebook_entry" within "#row_0 .testcase_name"
#    And I should see values "Pass,Pass,N/A,Pass" in columns of "#row_0 td"

#    And I should see "SMOKE-SIM-Get_IMSI" within "#row_10 .testcase_name"
#    And I should see values "Pass,Pass,N/A,Fail" in columns of "#row_10 td"




