Given(/^I am on a page with a textarea with markdown preview and autocompletion$/) do
  step %{I go to the open tasks page}
  step %{I follow "New"}
end

When(/^I fill in the markdown textarea with "@user" followed by my user id$/) do
  user = User.last
  step %{I fill in "task_description" with "@user#{user.id}"}
end

When(/^I fill in the markdown textarea with "@taxon" followed by Eciton's id$/) do
  eciton = Taxon.find_by name_cache: "Eciton"
  step %{I fill in "task_description" with "%taxon#{eciton.id}"}
end

# HACK because the below selects the wrong suggestion (which is hidden).
#   `first(".atwho-view-ul li.cur", visible: true).click`
When(/^I click the suggestion containing "(.*?)"$/) do |text|
  find(".atwho-view-ul li", text: text).click
end

Then(/^the markdown textarea should contain "(.*?)"$/) do |text|
  expect(markdown_textarea.value).to include text
end

Then(/^the markdown textarea should contain a markdown link to Archibald's user page$/) do
  archibald = User.find_by name: "Archibald"
  expect(markdown_textarea.value).to include "@user#{archibald.id}"
end

Then(/^the markdown textarea should contain a markdown link to Eciton$/) do
  eciton = Taxon.find_by name_cache: "Eciton"
  expect(markdown_textarea.value).to include "%taxon#{eciton.id}"
end

When(/^I clear the markdown textarea$/) do
  markdown_textarea.set ""
end

Then(/^there should be a textarea with markdown and autocompletion$/) do
  find "textarea[data-previewable]"
  find "textarea[data-has-mentionables]"
  find "textarea[data-has-linkables]"
end

def markdown_textarea
  find ".preview-area textarea"
end
