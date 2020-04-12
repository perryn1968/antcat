# frozen_string_literal: true

require 'rails_helper'

describe ReferenceObserver do
  describe "`NestedReference`s" do
    context "when a nesting_reference is changed" do
      let!(:nesting_reference) { create :article_reference }
      let!(:nested_reference) { create :nested_reference, nesting_reference: nesting_reference }

      before do
        References::Cache::Regenerate[nesting_reference]
        nesting_reference.reload
        References::Cache::Regenerate[nested_reference]
        nested_reference.reload
      end

      it "invalidates the cache for itself and its nestees" do
        expect(nesting_reference.plain_text_cache).not_to eq nil
        expect(nested_reference.plain_text_cache).not_to eq nil

        nesting_reference.update!(title: "New Title")

        expect(nesting_reference.reload.plain_text_cache).to eq nil
        expect(nested_reference.reload.plain_text_cache).to eq nil
      end
    end

    describe "Handling a network" do
      let!(:nesting_reference) { create :article_reference }
      let!(:nested_reference) { create :nested_reference, nesting_reference: nesting_reference }

      before do
        References::Cache::Regenerate[nesting_reference]
        nesting_reference.reload
        References::Cache::Regenerate[nested_reference]
        nested_reference.reload
      end

      it "invalidates each member of the network" do
        expect(nesting_reference.plain_text_cache).not_to eq nil
        expect(nested_reference.plain_text_cache).not_to eq nil

        nesting_reference.reference_author_names.first.update!(position: 4)

        expect(nesting_reference.reload.plain_text_cache).to eq nil
        expect(nested_reference.reload.plain_text_cache).to eq nil
      end
    end
  end
end
