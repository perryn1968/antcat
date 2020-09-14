Feature: Copy reference
  As Phil Ward
  I want to add new references using existing reference data
  So that I can reduce copy and pasting beteen references
  And so that the bibliography continues to be up-to-date

  Background:
    Given I log in as a helper editor

  Scenario: Copy an `ArticleReference`
    Given this article reference exists
      | author     | title          | citation | year | year_suffix | stated_year |
      | Ward, P.S. | Annals of Ants | Ants 1:2 | 1910 | b           | 1911        |
    And I go to the page of the most recent reference

    When I follow "Copy"
    Then the "reference_author_names_string" field should contain "Ward, P.S."
    And the "reference_year" field should contain "1910"
    And the "reference_year_suffix" field should contain "b"
    And the "reference_stated_year" field should contain "1911"
    And the "reference_pagination" field should contain "2"
    And the "reference_journal_name" field should contain "Ants"
    And the "reference_series_volume_issue" field should contain "1"
