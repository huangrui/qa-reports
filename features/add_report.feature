Feature:
  As a test engineer
  I want to add existing test run reports
  So that stakeholders can easily see the current status

  Background:
    Given I am a new, authenticated user

  @smoke
  Scenario: The front page should show the add report link
    When I am on the front page

    Then I should not see "Sign In"

    And I should see "Add report"

  Scenario: Should see publish notification
    When I follow "Add report"
    And I select target "Handset", test set "Smokey" and hardware "N990" with date "2010-11-22"
    And I attach the report "sim.xml"
    And submit the form at "upload_report_submit"
    And I press "Publish"

    Then I should see "Your report has been successfully published"

  Scenario: Should not see publish notification after reloading report
    When I follow "Add report"
    And I select target "Handset", test set "Smokey" and hardware "N990" with date "2010-11-22"
    And I attach the report "sim.xml"
    And submit the form at "upload_report_submit"
    And I press "Publish"
    And I view the report "1.2/Handset/Smokey/N990"

    Then I should not see "Your report has been successfully published"

  Scenario Outline: Add new report with valid data
    When I follow "Add report"

    And I select target "Handset", test set "Smokey" and hardware "N990" with date "2010-11-22"
    And I attach the report "<attachment>"

    And submit the form at "upload_report_submit"

    Then I should see "<expected text>"
    And I should see "<expected link>"

    And I should see "Publish"
    And I should see "Handset Test Report: N990 Smokey 2010-11-22"

  Examples:
    | attachment                | expected text                    | expected link |
    | sample.csv                | Check home screen                | 3921          |
    | filesystem.xml            | NFT-FS-Create_Directory_TMP-LATE | Fail          |
    | sim.xml                   | SMOKE-SIM-Get_IMSI               | Fail          |
    | all_na.xml                | NFT-BT-Device_Scan_C-ITER        | N/A           |
    | bug9767_result.xml        | case#1.1.1                       | Fail          |

  Scenario: Add new report with invalid filename extension
    When I follow "Add report"

    And I select target "Core", test set "Smokey" and hardware "n990"
    And I attach the report "invalid_ext.txt"

    And submit the form at "upload_report_submit"

    Then I should see "You can only upload files with the extension .xml or .csv"

  Scenario: Add new CSV report with invalid content

    When I follow "Add report"

    And I select target "Core", test set "Smokey" and hardware "n990"
    And I attach the report "invalid.csv"

    And submit the form at "upload_report_submit"

    Then I should see "Incorrect file format"


  Scenario: Add new CSV report with no test cases

    When I follow "Add report"

    And I select target "Core", test set "Smokey" and hardware "n990"
    And I attach the report "empty.csv"

    And submit the form at "upload_report_submit"

    Then I should see "didn't contain any valid test cases"

  Scenario: Add new XML report with no test cases

    When I follow "Add report"

    And I select target "Core", test set "Smokey" and hardware "n990"
    And I attach the report "empty.xml"

    And submit the form at "upload_report_submit"

    Then I should see "didn't contain any valid test cases"


  Scenario: Add new XML report with invalid content

    When I follow "Add report"

    And I select target "Core", test set "Smokey" and hardware "n990"
    And I attach the report "invalid.xml"

    And submit the form at "upload_report_submit"

    Then I should see "Incorrect file format"

  Scenario: Try to submit without uploading a file

    When I follow "Add report"

    And I select target "Core", test set "Smokey" and hardware "n990"

    And submit the form at "upload_report_submit"

    Then I should see "be blank"

  Scenario: Add new report with saved default target
    When I follow "Add report"

    And I select target "Handset", test set "Smokey" and hardware "n990" with date "2010-02-12"
    And I attach the report "sample.csv"
    And submit the form at "upload_report_submit"
    And submit the form at "upload_report_submit"

    Then I should see "Check home screen"
    And I should see "Handset" within "h1"

    When I follow "Add report"
    And I select test set "Smokey" and hardware "n990" with date "2010-02-12"

    And I attach the report "sample.csv"
    And submit the form at "upload_report_submit"

    Then I should see "Check home screen"
    And I should see "Handset" within "h1"

  #  @selenium
  #  Scenario: Add new report with underscore in test set and hardware names
  #    When I follow "Add report"
  #
  #    And I select target "Handset", test set "test_set" and hardware "hardware_32" with date "2010-02-12"
  #    And I attach the report "sample.csv"
  #    And submit the form at "upload_report_submit"
  #    And I press "Publish"
  #
  #    When I go to the front page
  #    And I follow "Hardware_32"
  #
  #    Then I should see "Test_set" within ".index_month .odd .report_name"
  #    Then I should see "Hardware_32" within ".index_month .odd .report_name"
