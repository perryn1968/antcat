Given("there is a reference") do
  @reference = create :article_reference
end

Given("there is an article reference") do
  @reference = create :article_reference
end

Given("there is a book reference") do
  @reference = create :book_reference
end

Given("this/these reference(s) exist(s)") do |table|
  table.hashes.each do |hash|
    citation = hash.delete('citation') || "Psyche 1:1"
    matches = citation.match /(\w+) (\d+):([\d\-]+)/
    journal = create :journal, name: matches[1]

    hash.merge! journal: journal, series_volume_issue: matches[2], pagination: matches[3]

    create_reference :article_reference, hash
  end
end

Given("these/this book reference(s) exist(s)") do |table|
  table.hashes.each do |hash|
    citation = hash.delete 'citation'
    matches = citation.match /([^:]+): (\w+), (.*)/

    publisher = create :publisher, name: matches[2], place_name: matches[1]
    hash.merge! publisher: publisher, pagination: matches[3]
    create_reference :book_reference, hash
  end
end

# HACK because I could not get it to work in any other way.
# Special cases because we want specific IDs.
Given("there is a Giovanni reference") do
  reference = create :article_reference,
    citation_year: '1809',
    title: "Giovanni's Favorite Ants"

  reference.update_column :id, 7777
  reference.author_names << create(:author_name, name: 'Giovanni, S.')
end

Given("there is a reference by Giovanni's brother") do
  reference = create :article_reference,
    citation_year: '1800',
    title: "Giovanni's Brother's Favorite Ants"

  reference.update_column :id, 7778
  reference.author_names << create(:author_name, name: 'Giovanni, J.')
end

Given("these/this unknown reference(s) exist(s)") do |table|
  table.hashes.each { |hash| create_reference :unknown_reference, hash }
end

def create_reference type, hash
  author = hash.delete 'author'
  author_names =
    if author
      [create(:author_name, name: author)]
    else
      authors = hash.delete 'authors'
      parsed_author_names = Parsers::AuthorParser.parse(authors)[:names]
      author_names_suffix = Parsers::AuthorParser.parse(authors)[:suffix]
      parsed_author_names.map do |author_name|
        AuthorName.find_by(name: author_name) || create(:author_name, name: author_name)
      end
    end

  hash[:year] = hash.delete('year').to_i
  hash[:citation_year] =
    if hash[:citation_year].present?
      hash.delete('citation_year').to_s
    else
      hash[:year].to_s
    end

  @reference = create type, hash.merge(author_names: author_names, author_names_suffix: author_names_suffix)
end

Given("the following entry nests it") do |table|
  data = table.hashes.first
  nestee_reference = @reference
  @reference = NestedReference.create! title: data[:title],
    author_names: [create(:author_name, name: data[:authors])],
    citation_year: data[:year],
    pages_in: data[:pages_in],
    nesting_reference: nestee_reference
end

Given("that the entry has a URL that's on our site") do
  @reference.update_attribute :document, ReferenceDocument.create!
  @reference.document.update file_file_name: '123.pdf',
    url: "localhost/documents/#{@reference.document.id}/123.pdf"
end

When('I fill in "reference_nesting_reference_id" with the ID for {string}') do |title|
  reference = Reference.find_by(title: title)
  step %(I fill in "reference_nesting_reference_id" with "#{reference.id}")
end

Then("I should see a PDF link") do
  find "a", text: "PDF", match: :first
end

When("I fill in {string} with a URL to a document that exists") do |field|
  stub_request :any, "google.com/foo"
  step %(I fill in "#{field}" with "google\.com/foo")
end

When("I fill in {string} with a URL to a document that doesn't exist in the first reference") do |field|
  stub_request(:any, "google.com/foo").to_return status: 404
  step %(I fill in "#{field}" with "google\.com/foo")
end

Given "there is a reference with ID 50000 for Dolerichoderinae" do
  reference = create :unknown_reference, title: 'Dolerichoderinae'
  reference.update_column :id, 50000
end

Given("there is a missing reference") do
  create :missing_reference
end

Then("I should not see the missing reference") do
  step 'I should not see "Adventures among Ants"'
end

def find_reference_by_keey keey
  parts = keey.split ' '
  last_name = parts[0]
  year = parts[1]
  Reference.find_by(principal_author_last_name_cache: last_name, year: year.to_i)
end

Given("the default reference is {string}") do |keey|
  reference = find_reference_by_keey keey
  DefaultReference.stub(:get).and_return reference
end

Given("there is no default reference") do
  DefaultReference.stub(:get).and_return nil
end

When("I fill in the references search box with {string}") do |search_term|
  within "#breadcrumbs" do
    step %(I fill in "reference_q" with "#{search_term}")
  end
end

When("I fill in the references authors search box with {string}") do |search_term|
  within "#breadcrumbs" do
    step %(I fill in "author_q" with "#{search_term}")
  end
end

When("I select author search from the search type selector") do
  select "author", from: "search_type"
end

When('I press "Go" by the references search box') do
  within ".reference-search-form" do
    step 'I press "Go"'
  end
end

When("I hover the export button") do
  find(".btn-normal", text: "Export").hover
end

Then("nesting_reference_id should contain a valid reference id") do
  id = find("#reference_nesting_reference_id").value
  expect(Reference.exists?(id)).to be true
end

Given("there is a taxon with that reference as its protonym's reference") do
  taxon = create_genus
  taxon.protonym.authorship.reference = @reference
  taxon.protonym.authorship.save!
end

Then("the {string} tab should be selected") do |tab_name|
  tab_name = 'Unknown' if tab_name == 'Other'
  find("#tabs-#{tab_name.downcase}.is-active")
end
