Feature: View reference
  As a researcher
  I want to drill down to a specific reference
  So that I can get more information than the index show
  Like the ID

  Scenario: View a reference
    Given the following entry exists in the bibliography
      |authors|citation|cite_code|created_at|date    |excel_file_name|notes|possess|title|updated_at|year|
      |Authors|Citation|CiteCode |today     |20100712|ExcelFileName  |Notes|Possess|Title|today     |2010|
    When I go to the main page
      And I follow "Authors 2010 Title Citation Notes"
    Then I should be on the page for that reference
