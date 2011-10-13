Feature:
  As a Meego QA engineer
  I want to be able to rename testsets and products
  So that I can better reorganize and manage reports

  Background:
    Given I have uploaded reports with profile "Core" having testset "foo" and product "N900"
    And I have uploaded reports with profile "Handset" having testset "foo" and product "N900"
    And I have uploaded reports with profile "Handset" having testset "foo" and product "Pinetrail"
    Given I am logged in
    And I am on the front page

  @selenium
  Scenario: Rename testset
    When I click on the edit button
    And  I edit the testset name "foo" to "bar" for profile "Core"
    And  I press enter

    Then I should see testset "bar" for profile "Core"
    And  I should see testset "foo" for profile "Handset"

  @selenium
  Scenario: Cancel testset renaming
    When I click on the edit button
    And I edit the testset name "foo" to "bar" for profile "Core"
    And I press escape

    When I click done
    And I reload the front page

    Then I should see testset "foo" for profile "Core"
    And I should see testset "foo" for profile "Handset"

  @selenium
  Scenario: Rename product
    When I rename the product "N900" to "N950"
    And I reload the front page

    Then I should see "N950"
    But I should not see "N900"

  @selenium
  Scenario: Cancel product renaming
    When I click on the edit button
    And I edit the product name "N900" to "N950"
    And I press escape

    Then I should see "N900"
    But I should not see "N950"

  @selenium
  Scenario: Rename report titles according to new testset and product names
    When I rename the testset "foo" under profile "Core" to "bar"
    And I rename the product "N900" to "N950"
    And I view the group report for "Core/bar"
    And I scroll down the page

    Then I should see "N950" in test reports titles
    And I should see "bar" in test reports titles
    But I should not see "foo" in test reports titles

    When I view the group report for "Handset/foo"

    Then I should see "foo" in test reports titles
    But I should not see "bar" in test reports titles
