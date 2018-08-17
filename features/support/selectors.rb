module HtmlSelectorsHelpers
  def selector_for locator
    case locator

    # TODO change this or wherever the "default element" is defined to
    # "html > body #content" and use "I should see in the header" where required.
    # It would make error messages easier to read and steps easier to read/write
    # (less "I follow the first").
    when /the page/
      "html > body"

    # Catalog.
    when /the index/ # TODO rename
      "#taxon_browser"
    when /the (\w*) index/
      tab_title_target = find(:link, $1)[:href]
      tab_title_target
    when /the taxon description/
      "#taxon_description"
    when /the protonym/
      "#taxon_description .headline > b > span"
    when /the type name/
      "#taxon_description .type"
    when /the header/
      "div.header"
    when /the headline/
      '.headline'

    # Catalog search.
    when /the search box/
      "#q"
    when /the catalog search box/
      "#qq"
    when /the search results/
      "table"
    when /the search section/
      "#advanced_search"

    # Merge authors.
    when /the author panel/, /the first author panel/
      find ".author_panel", match: :first
    when /the last author panel/
      all(".author_panel").last
    when /the second author panel/
      all(".author_panel")[1]
    when /another author panel/
      all(".author_panel").last

    # Editing.
    when /^the junior synonyms section$/
      '#junior-synonyms-section-test-hook'
    when /^the senior synonyms section$/
      '#senior-synonyms-section-test-hook'

    # Test pages.
    when /the name field/
      '#test_name_field .display'
    when /the allow_blank name field/
      '#test_allow_blank_name_field .display'
    when /the new_or_homonym name field/
      '#test_new_or_homonym_name_field .display'

    # Users.
    when /the users list/
      '#content table'

    when /the left side of the diff/
      all(".callout .diff")[0]
    when /the right side of the diff/
      all(".callout .diff")[1]

    when /"(.+)"/
      $1

    else
      raise %(Can't find mapping from "#{locator}" to a selector)
    end
  end
end

World HtmlSelectorsHelpers
World FactoryBot::Syntax::Methods # To avoid typing `FactoryBot.create`.
