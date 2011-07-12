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

  Scenario: Uploading test report with HTTP POST with RESTful parameters
    When the client sends file "bluetooth.xml" via the REST API with RESTful parameters

    Then the REST result "ok" is "1"
    And I should be able to view the created report

  Scenario: Uploading test report with multiple files and attachments
    When the client sends file with attachments via the REST API
    Then the REST result "ok" is "1"
    And I should be able to view the created report

    Then I should see "SIM"
    And I should see "BT"

    And I should see "ajax-loader.gif" within "#file_attachment_list"
    And I should see "icon_alert.gif" within "#file_attachment_list"

  Scenario: Adding a report with tests that do not belong to any feature
    When the client sends reports "spec/fixtures/no_features.xml" via the REST API to test set "Automated" and product "N900"
    And I should be able to view the created report

    Then I should see "N/A" within ".feature_name"
    And I should see "8" within "td.total"

  Scenario: Adding a report with tests that do not belong to any feature vie the new API
    When the client sends reports "spec/fixtures/no_features.xml" via the new REST API to test set "Automated" and product "N900"
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

  Scenario: Sending REST import with user defined report title
    When the client sends a request with optional parameter "title" with value "My Test Report" via the REST API

    Then the REST result "ok" is "1"
    And I should be able to view the created report

    Then I should see "My Test Report"

  Scenario: Sending REST import with user defined test objective
    When the client sends a request with optional parameter "objective_txt" with value "To test that [[1234]] works now" via the REST API

    Then the REST result "ok" is "1"
    And I should be able to view the created report

    Then I should see "To test that 1234 works now"

  Scenario: Sending REST import first with user defined test objective and then without
    Given I have sent a request with optional parameter "objective_txt" with value "To notice regression" via the REST API

    When the client sends file "sim.xml" via the REST API

    Then the REST result "ok" is "1"
    And I should be able to view the latest created report

    Then I should see "To notice regression"

  Scenario: Sending REST import without user defined test environment
    When the client sends file "sim.xml" via the REST API
    Then the REST result "ok" is "1"

    And I should be able to view the latest created report
    Then I should see "Product: N900"


  # For the optional parameters, title, build_txt/Build (image), objective_txt (Test Objective), qa_summary_txt/(Quality Summary), issue_summary_txt
  Scenario: Sending REST import with valid optional title parameter
    When the client sends a request with extra parameter "title=Core+Test+Report%3A+N900+UX+Key+Feature+%2D+20110320+%28for+0315+release%29" via the REST API

    Then the REST result "ok" is "1"
    And I should be able to view the created report
    And I should see "Core Test Report: N900 UX Key Feature - 20110320 (for 0315 release)" within "h1"


  Scenario: Sending REST import with valid optional build_image parameter
    When the client sends a request with extra parameter "build_txt=meego%2Dtablet%2Dia32%2Dproduct%2DPinetrail%2D1%2E1%2E90%2E7%2E20110315%2E10%2Eiso" via the REST API

    Then the REST result "ok" is "1"
    And I should be able to view the created report
    And I should see "meego-tablet-ia32-product-Pinetrail-1.1.90.7.20110315.10.iso"


  Scenario: Sending REST import with an optional objective_txt parameter
    When the client sends a request with extra parameter "objective_txt=It+is+a+weekly+testing+cycle+for+preview+images+released+by+distribution+team+to+ensure+MeeGo+Tablet+UX+delivers+correct+software+feature+integrations+and+stable+existed+functions%2E+Based+on+the+Tablet+requirements+documented%2C+our+testing+focus+would+be+basic+feature+testing%2C+bug+verification+and+regression+test+according+to+package+changes%2E" via the REST API

    Then the REST result "ok" is "1"
    And I should be able to view the created report
    And I should see "It is a weekly testing cycle for preview images released by distribution team to ensure MeeGo Tablet UX delivers correct software feature integrations and stable existed functions. Based on the Tablet requirements documented, our testing focus would be basic feature testing, bug verification and regression test according to package changes."


  Scenario: Sending REST import with valid optional qa_summary_txt parameter
    When the client sends a request with extra parameter "qa_summary_txt=Improvement%3A%2D+Notification+UX+can+be+shown+now+%28top+bug+5518+is+fixed%29%2C+but+new+IM+message+failed+to+show+in+notification+UI%3B%2D+Be+able+to+transfer+files+using+Chat%3B" via the REST API

    Then the REST result "ok" is "1"
    And I should be able to view the created report
    And I should see "Improvement:- Notification UX can be shown now (top bug 5518 is fixed), but new IM message failed to show in notification UI;- Be able to transfer files using Chat;"


  Scenario: Sending REST import with valid optional issue_summary_txt
    When the client sends a request with extra parameter "issue_summary_txt=New+Issue%285%29%3A6306+System+time+setting+is+wrong+for+Los+Angeles%3B+6235+VKB+in+browser+does+not+launch+in+some+text+fields%3B+6043+Mismatched+sync+service+icon+and+text+in+Sync+Details+page%3B+6055+Sync+shared+credentials+not+reflected+in+Sync+Settings+main+page%3B+6056+Sync+UI+intermittent+crash+after+log+in" via the REST API

    Then the REST result "ok" is "1"
    And I should be able to view the created report
    And I should see "New Issue(5):6306 System time setting is wrong for Los Angeles; 6235 VKB in browser does not launch in some text fields; 6043 Mismatched sync service icon and text in Sync Details page; 6055 Sync shared credentials not reflected in Sync Settings main page; 6056 Sync UI intermittent crash after log in"

  Scenario: Sending REST import with all valid optional parameters
    When the client sends a request with extra parameter "title=Core+Test+Report%3A+N900+UX+Key+Feature+%2D+20110320+%28for+0315+release%29&build_txt=meego%2Dtablet%2Dia32%2Dproduct%2DPinetrail%2D1%2E1%2E90%2E7%2E20110315%2E10%2Eiso&objective_txt=It+is+a+weekly+testing+cycle+for+preview+images+released+by+distribution+team+to+ensure+MeeGo+Tablet+UX+delivers+correct+software+feature+integrations+and+stable+existed+functions%2E+Based+on+the+Tablet+requirements+documented%2C+our+testing+focus+would+be+basic+feature+testing%2C+bug+verification+and+regression+test+according+to+package+changes%2E&qa_summary_txt=Improvement%3A%2D+Notification+UX+can+be+shown+now+%28top+bug+5518+is+fixed%29%2C+but+new+IM+message+failed+to+show+in+notification+UI%3B%2D+Be+able+to+transfer+files+using+Chat%3B&issue_summary_txt=New+Issue%285%29%3A6306+System+time+setting+is+wrong+for+Los+Angeles%3B+6235+VKB+in+browser+does+not+launch+in+some+text+fields%3B+6043+Mismatched+sync+service+icon+and+text+in+Sync+Details+page%3B+6055+Sync+shared+credentials+not+reflected+in+Sync+Settings+main+page%3B+6056+Sync+UI+intermittent+crash+after+log+in" via the REST API

    Then the REST result "ok" is "1"
    And I should be able to view the created report

    And I should see "Core Test Report: N900 UX Key Feature - 20110320 (for 0315 release)" within "h1"
    And I should see "meego-tablet-ia32-product-Pinetrail-1.1.90.7.20110315.10.iso"
    And I should see "It is a weekly testing cycle for preview images released by distribution team to ensure MeeGo Tablet UX delivers correct software feature integrations and stable existed functions. Based on the Tablet requirements documented, our testing focus would be basic feature testing, bug verification and regression test according to package changes."
    And I should see "Improvement:- Notification UX can be shown now (top bug 5518 is fixed), but new IM message failed to show in notification UI;- Be able to transfer files using Chat;"
    And I should see "New Issue(5):6306 System time setting is wrong for Los Angeles; 6235 VKB in browser does not launch in some text fields; 6043 Mismatched sync service icon and text in Sync Details page; 6055 Sync shared credentials not reflected in Sync Settings main page; 6056 Sync UI intermittent crash after log in"

  Scenario: Getting a list of sessions from API
    When the client sends file "short1.csv" via the REST API
    When the client sends file "short2.csv" via the REST API
    When the client sends file "short3.csv" via the REST API
    And session "short1.csv" has been modified at "2011-01-01 01:01"
    And session "short2.csv" has been modified at "2011-02-01 01:01"
    And session "short3.csv" has been modified at "2011-03-01 01:01"
    When I download "/api/reports/since/2011-01-10%2012:00" with limit "1"
    Then resulting JSON should match file "short2.csv"
