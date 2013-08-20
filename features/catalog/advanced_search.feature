Feature: Searching the catalog
  As a user of AntCat
  I want to search the catalog in index view
  So that I can find taxa with their parents and siblings

  Scenario: Searching when not logged in
    When I go to the catalog
    And I follow "Advanced Search"
    Then I should be on the advanced search page

  Scenario: Searching when no results
    When I go to the catalog
    And I follow "Advanced Search"
    And I fill in "year" with "2010"
    And I press "Go" in the search section
    Then I should see "No results found"

  Scenario: Searching when one result
    Given there is a species described in 2010
    And there is a species described in 2011
    When I go to the catalog
    And I follow "Advanced Search"
    And I fill in "year" with "2010"
    And I press "Go" in the search section
    Then I should see "1 result found"
    And I should see the species described in 2010