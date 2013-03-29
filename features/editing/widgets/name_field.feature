@javascript
Feature: Name field

  Scenario: Find typed taxon
    Given there is a genus called "Atta"
    When I go to the name field test page
    And I click the name field
    And I fill in "name_string" with "Atta"
    And I press "OK"
    Then I should see "Atta" in the name field

  Scenario: Find typed name
    Given there is a species name "Eciton major"
    When I go to the name field test page
    And I click the name field
    And I fill in "name_string" with "Eciton major"
    And I press "OK"
    Then I should see "Eciton major" in the name field

  Scenario: Adding a name
    When I go to the name field test page
    And I click the name field
    And I fill in "name_string" with "Atta wildensis"
    And I press "OK"
    Then I should see "Do you want to add the name Atta wildensis? You can attach it to a taxon later, if desired."
    And I press "Add this name"
    Then I should see "Atta wildensis" in the name field

  Scenario: Blank name
    When I go to the name field test page
    And I click the name field
    And I press "OK"
    # blank entry is simply ignored
    Then I should not see "Name can't be blank"
    And I should not see "Do you want to add the name?"

  Scenario: Cancelling an add
    When I go to the name field test page
    And I click the name field
    And I fill in "name_string" with "Atta wildensis"
    And I press "OK"
    Then I should see "Do you want to add the name Atta wildensis? You can attach it to a taxon later, if desired."
    And I press "Cancel"
    Then I should not see "Add this name"