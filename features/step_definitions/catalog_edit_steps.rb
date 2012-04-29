# coding: UTF-8
Then /^the history should be "(.*)"$/ do |history|
  page.find('div.display').text.should =~ /#{history}\.?/
end

When /^I click the edit icon$/ do
  step 'I follow "edit"'
end

When /^I edit the history item to "([^"]*)"$/ do |history|
  step %{I fill in "taxt_editor" with "#{history}"}
end

Given /^I edit the history item to include that reference$/ do
  key = Taxt.id_for_editable @reference.id
  step %{I edit the history item to "{#{key}}"}
end

When /^I save my changes$/ do
  step 'I press "Save"'
  step 'I wait for a bit'
end

When /^I save the form$/ do
  step 'I save my changes'
end

When /In the search box, I press "Go"/ do
  step 'I press "Go" within ".search_form"'
end

Given /^there is a reference for "Bolton, 2005"$/ do
  @reference = Factory :article_reference, :author_names => [Factory(:author_name, :name => 'Bolton')], :citation_year => '2005'
end

Then /^I should see an error message about the unfound reference$/ do
  step %{I should see "The reference '{123}' could not be found. Was the ID changed?"}
end

When /^I search for "([^"]*)"$/ do |search_term|
  # this is to make the selectmenu work
  step %{I follow "Search for"}
  step %{I follow "Search for"}
  step "I fill in the search box with \"#{search_term}\""
  step %{In the search box, I press "Go"}
end

When /^I search for the authors "([^"]*)"$/ do |authors|
  step %{I follow "Search for author(s)"}
  step %{I fill in the search box with "Bolton, B.;Fisher, B."}
  step %{In the search box, I press "Go"}
end

When /^I go to the reference picker widget test page, opened to the first reference$/ do
  visit "/widget_tests/reference_picker?id=#{Reference.first.id}"
end

When /^I go to the reference field widget test page$/ do
  visit "/widget_tests/reference_field"
end

When /^I edit the reference$/ do
  within ".current_reference" do
    step 'I follow "edit"'
  end
end

When /^I set the authors to "([^"]*)"$/ do |names|
  within ".current_reference div.edit" do
    step %{I fill in "reference_author_names_string" with "#{names}"}
  end
end

When /^I set the title to "([^"]*)"$/ do |title|
  within ".current_reference div.edit" do
    step %{I fill in "reference_title" with "#{title}"}
  end
end

When /^I set the genus name to "([^"]*)"$/ do |name|
  step %{I fill in "genus_name" with "#{name}"}
end

When /^I add a reference and choose it for the protonym/ do
  #"I add a reference"
  #"I click OK to choose the reference"
end

When /^I add a reference by Brian Fisher$/ do
  step 'I press "Add"'
  step %{I fill in "reference_author_names_string" with "Fisher, B.L."}
end
