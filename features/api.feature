Feature: REST API
  As an external service
  I want to upload reports via REST API
  So that they can be browsed by users

  Background:
    Given I am an user with a REST authentication token

  Scenario: Uploading a test report with single basic file
    When the client sends a basic test result file
    Then the upload succeeds
    And I should be able to view the created report

  Scenario: Uploading a test report with multiple files and attachments
    When the client sends files with attachments
    Then the upload succeeds
    And I should be able to view the created report

    Then I should see names of the two features
    And I should see the uploaded attachments

  Scenario: Adding a report with tests that do not belong to any feature
    When the client sends a report with tests without features
    Then the upload succeeds
    And I should be able to view the created report

    Then I should see an unnamed feature section
    And I should see the correct amount of test cases without a feature

  Scenario: Adding a report with deprecated parameters
    When the client sends a basic test result file with deprecated parameters
    Then the upload succeeds
    And I should be able to view the created report

  Scenario: Adding a report with deprecated product parameter
    When the client sends a basic test result file with deprecated product parameter
    Then the upload succeeds
    And I should be able to view the created report

  Scenario: Sending a report with string values instead of files
    When the client sends a request with string value instead of a file
    Then the upload fails
    And the result complains about invalid file

  Scenario: Sending a report without a valid report file
    When the client sends a request without file
    Then the upload fails
    And the result complains about missing file

  Scenario: Sending a report without a target profile
    When the client sends a request without a target profile
    Then the upload fails
    And the result complains about missing target profile    

  Scenario: Sending a report with invalid extra parameters
    When the client sends a request containing invalid extra parameter
    Then the upload fails
    And the result complains about invalid parameter

  Scenario: Sending a report with a user defined report title
    When the client sends a request with a defined title
    Then the upload succeeds
    And I should be able to view the created report
    And I should see the defined report title

  Scenario: Sending a report with user defined test objective
    When the client sends a request with defined test objective
    Then the upload succeeds
    And I should be able to view the created report
    And I should see the defined test objective

  Scenario: Test objective is copied from previous report if not given
    Given the client has sent a request with a defined test objective
    When the client sends a basic test result file

    Then the upload succeeds
    And I should be able to view the latest created report
    And I should see the objective of previous report

  # For the optional parameters, title, build_txt/Build (image), objective_txt (Test Objective), qa_summary_txt/(Quality Summary), issue_summary_txt
  Scenario: Sending REST import with valid optional title parameter
    When the client sends a request with extra parameter "title=Core+Test+Report%3A+N900+UX+Key+Feature+%2D+20110320+%28for+0315+release%29"

    Then the upload succeeds
    And I should be able to view the created report
    And I should see "Core Test Report: N900 UX Key Feature - 20110320 (for 0315 release)" within "h1"


  Scenario: Sending REST import with valid optional build_image parameter
    When the client sends a request with extra parameter "build_txt=meego%2Dtablet%2Dia32%2Dproduct%2DPinetrail%2D1%2E1%2E90%2E7%2E20110315%2E10%2Eiso"

    Then the upload succeeds
    And I should be able to view the created report
    And I should see "meego-tablet-ia32-product-Pinetrail-1.1.90.7.20110315.10.iso"


  Scenario: Sending REST import with an optional objective_txt parameter
    When the client sends a request with extra parameter "objective_txt=It+is+a+weekly+testing+cycle+for+preview+images+released+by+distribution+team+to+ensure+MeeGo+Tablet+UX+delivers+correct+software+feature+integrations+and+stable+existed+functions%2E+Based+on+the+Tablet+requirements+documented%2C+our+testing+focus+would+be+basic+feature+testing%2C+bug+verification+and+regression+test+according+to+package+changes%2E"

    Then the upload succeeds
    And I should be able to view the created report
    And I should see "It is a weekly testing cycle for preview images released by distribution team to ensure MeeGo Tablet UX delivers correct software feature integrations and stable existed functions. Based on the Tablet requirements documented, our testing focus would be basic feature testing, bug verification and regression test according to package changes."


  Scenario: Sending REST import with valid optional qa_summary_txt parameter
    When the client sends a request with extra parameter "qa_summary_txt=Improvement%3A%2D+Notification+UX+can+be+shown+now+%28top+bug+5518+is+fixed%29%2C+but+new+IM+message+failed+to+show+in+notification+UI%3B%2D+Be+able+to+transfer+files+using+Chat%3B"

    Then the upload succeeds
    And I should be able to view the created report
    And I should see "Improvement:- Notification UX can be shown now (top bug 5518 is fixed), but new IM message failed to show in notification UI;- Be able to transfer files using Chat;"


  Scenario: Sending REST import with valid optional issue_summary_txt
    When the client sends a request with extra parameter "issue_summary_txt=New+Issue%285%29%3A6306+System+time+setting+is+wrong+for+Los+Angeles%3B+6235+VKB+in+browser+does+not+launch+in+some+text+fields%3B+6043+Mismatched+sync+service+icon+and+text+in+Sync+Details+page%3B+6055+Sync+shared+credentials+not+reflected+in+Sync+Settings+main+page%3B+6056+Sync+UI+intermittent+crash+after+log+in"

    Then the upload succeeds
    And I should be able to view the created report
    And I should see "New Issue(5):6306 System time setting is wrong for Los Angeles; 6235 VKB in browser does not launch in some text fields; 6043 Mismatched sync service icon and text in Sync Details page; 6055 Sync shared credentials not reflected in Sync Settings main page; 6056 Sync UI intermittent crash after log in"

  Scenario: Sending REST import with all valid optional parameters
    When the client sends a request with extra parameter "title=Core+Test+Report%3A+N900+UX+Key+Feature+%2D+20110320+%28for+0315+release%29&build_txt=meego%2Dtablet%2Dia32%2Dproduct%2DPinetrail%2D1%2E1%2E90%2E7%2E20110315%2E10%2Eiso&objective_txt=It+is+a+weekly+testing+cycle+for+preview+images+released+by+distribution+team+to+ensure+MeeGo+Tablet+UX+delivers+correct+software+feature+integrations+and+stable+existed+functions%2E+Based+on+the+Tablet+requirements+documented%2C+our+testing+focus+would+be+basic+feature+testing%2C+bug+verification+and+regression+test+according+to+package+changes%2E&qa_summary_txt=Improvement%3A%2D+Notification+UX+can+be+shown+now+%28top+bug+5518+is+fixed%29%2C+but+new+IM+message+failed+to+show+in+notification+UI%3B%2D+Be+able+to+transfer+files+using+Chat%3B&issue_summary_txt=New+Issue%285%29%3A6306+System+time+setting+is+wrong+for+Los+Angeles%3B+6235+VKB+in+browser+does+not+launch+in+some+text+fields%3B+6043+Mismatched+sync+service+icon+and+text+in+Sync+Details+page%3B+6055+Sync+shared+credentials+not+reflected+in+Sync+Settings+main+page%3B+6056+Sync+UI+intermittent+crash+after+log+in"

    Then the upload succeeds
    And I should be able to view the created report

    And I should see "Core Test Report: N900 UX Key Feature - 20110320 (for 0315 release)" within "h1"
    And I should see "meego-tablet-ia32-product-Pinetrail-1.1.90.7.20110315.10.iso"
    And I should see "It is a weekly testing cycle for preview images released by distribution team to ensure MeeGo Tablet UX delivers correct software feature integrations and stable existed functions. Based on the Tablet requirements documented, our testing focus would be basic feature testing, bug verification and regression test according to package changes."
    And I should see "Improvement:- Notification UX can be shown now (top bug 5518 is fixed), but new IM message failed to show in notification UI;- Be able to transfer files using Chat;"
    And I should see "New Issue(5):6306 System time setting is wrong for Los Angeles; 6235 VKB in browser does not launch in some text fields; 6043 Mismatched sync service icon and text in Sync Details page; 6055 Sync shared credentials not reflected in Sync Settings main page; 6056 Sync UI intermittent crash after log in"

  Scenario: Getting a list of sessions from API
    When the client sends three CSV files
    When I download "/api/reports?limit_amount=1&begin_time=2011-01-10%2012:00"
    Then resulting JSON should match file "short2.csv"

  Scenario: Getting a list of sessions from API without date
    When the client sends three CSV files
    When I download "/api/reports?limit_amount=1"
    Then resulting JSON should match file "short1.csv"
