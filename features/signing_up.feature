Feature: Signing up as a new user
  In order to gain access to submit test reports
  New MeeGo test engineers
  Want to be able to sign up

  Scenario: Signing up with unique email address
    Given I am not logged in
    When I sign up with unique email address
    Then I should be on the front page
    And I should see my username and "Sign out" button

  Scenario: Signing up with an already registered email address
    Given I am not logged in
    When I sign up with an already registered email address
    Then I should see "Email has already been taken"

  Scenario: Signing up without name, invalid email and not matching password confirmation
    Given I am not logged in
    When I sign up with invalid name, email and password
    Then I should see "Name can't be blank"
    And I should see "Email is invalid"
    And I should see "Password doesn't match confirmation"
