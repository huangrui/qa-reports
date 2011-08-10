Feature: Authentication
  In order to submit test reports to the system
  MeeGo test engineers
  Want to be able to log in to MeeGoQA

  Scenario: Log in with valid credentials
    Given I am not logged in
    And I am viewing a test report

    When I log in with valid credentials
    Then I should be redirected back to the report I was viewing
    And I should see my username and "Sign out" button

  Scenario: Log in with incorrect email
    Given there is no user with email "jamesbond@mi6.co.uk"

    When I go to the front page
    And I log in with email "jamesbond@mi6.co.uk" and password "octopussy"

    Then I should be on the login page
    And I should see "The email address or password you entered is incorrect"

  Scenario: Log in with correct email but incorrect password
    Given I have one user "Timothy Dalton" with email "jamesbond@mi6.co.uk" and password "pussygalore"

    When I go to the front page
    And I log in with email "jamesbond@mi6.co.uk" and password "octopussy"

    Then I should be on the login page
    And I should see "The email address or password you entered is incorrect"

  Scenario: Logging out
    Given I have one user "Timothy Dalton" with email "jamesbond@mi6.co.uk" and password "octopussy"
    And there exists a report for "1.1/Handset/Sanity/N900"

    When I go to the front page
    And I log in with email "jamesbond@mi6.co.uk" and password "octopussy"
    And I view the report "1.1/Handset/Sanity/N900"

    When I follow "Sign out" within ".h-navi"
    Then I should be on the front page
    And I should see "Sign In" within ".h-navi"
