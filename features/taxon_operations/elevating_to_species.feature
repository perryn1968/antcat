Feature: Elevating subspecies to species
  As an editor of AntCat
  I want to make a subspecies a species
  So the data is correct

  Background:
    Given I am logged in

  Scenario: Elevating subspecies to species
    Given there is a subspecies "Solenopsis speccus subbus" which is a subspecies of "Solenopsis speccus" in the genus "Solenopsis"

    When I go to the edit page for "Solenopsis speccus subbus"
    And I will confirm on the next step
    And I follow "Elevate to species"
    Then I should see "Subspecies was successfully elevated to a species."
    And I should see the catalog entry for "Solenopsis subbus"

    When I go to the edit page for "Solenopsis subbus"
    Then I should see "species of Solenopsis"

  Scenario: Only show button if showing a subspecies
    Given there is a species "Atta"

    When I go to the edit page for "Atta"
    Then I should not see "Elevate to species"

  Scenario: Elevating to species when the species name exists
    Given there is a subspecies "Solenopsis speccus subbus" which is a subspecies of "Solenopsis speccus" in the genus "Solenopsis"
    And there is a species "Solenopsis subbus"

    When I go to the edit page for "Solenopsis speccus subbus"
    And I will confirm on the next step
    And I follow "Elevate to species"
    Then I should see "Subspecies was successfully elevated to a species."
    And I should see the catalog entry for "Solenopsis subbus"
