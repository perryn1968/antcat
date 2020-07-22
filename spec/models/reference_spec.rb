# frozen_string_literal: true

require 'rails_helper'

describe Reference do
  it { is_expected.to be_versioned }
  it { is_expected.to delegate_method(:routed_url).to(:document).allow_nil }
  it { is_expected.to delegate_method(:downloadable?).to(:document).allow_nil }

  describe 'relations' do
    it { is_expected.to have_many(:reference_author_names).dependent(:destroy) }
    it { is_expected.to have_many(:citations).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:citations_from_type_names).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:nestees).dependent(:restrict_with_error) }
    it { is_expected.to have_one(:document).dependent(false) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :year }
    it { is_expected.to validate_presence_of :pagination }
    it { is_expected.to validate_presence_of :author_names }
    it { is_expected.to validate_presence_of :title }
    it { is_expected.to_not allow_values('<', '>').for(:doi) }

    it { is_expected.to allow_value('2000').for(:citation_year) }
    it { is_expected.to allow_value('2000a').for(:citation_year) }
    it { is_expected.to_not allow_value('2000A').for(:citation_year) }

    describe '`bolton_key` uniqueness' do
      let!(:conflict) { create :any_reference, bolton_key: 'Batiatus 2000' }
      let!(:duplicate) { create :any_reference }

      specify do
        expect { duplicate.bolton_key = conflict.bolton_key }.
          to change { duplicate.valid? }.from(true).to(false)
        expect(duplicate.errors[:bolton_key].first).to include "Bolton key has already been taken by"
        expect(duplicate.errors[:bolton_key].first).to include conflict.key_with_citation_year
      end
    end
  end

  describe 'callbacks' do
    it { is_expected.to strip_attributes(:public_notes, :editor_notes, :taxonomic_notes) }
    it { is_expected.to strip_attributes(:title, :date, :stated_year, :series_volume_issue, :doi, :bolton_key, :author_names_suffix) }

    describe "#set_year_from_citation_year" do
      context 'when `citation_year` contains a letter' do
        let(:reference) { create :any_reference, citation_year: '1910a' }

        it "ignores letters when setting `year`" do
          expect { reference.update!(citation_year: '2010b') }.
            to change { reference.reload.year }.from(1910).to(2010)
        end
      end
    end
  end

  describe "scopes" do
    describe ".order_by_author_names_and_year" do
      it "sorts by author_name plus year plus letter" do
        one = create :any_reference, author_string: 'Fisher', citation_year: '1910b'
        two = create :any_reference, author_string: 'Wheeler', citation_year: '1874'
        three = create :any_reference, author_string: 'Fisher', citation_year: '1910a'

        expect(described_class.order_by_author_names_and_year).to eq [three, one, two]
      end
    end
  end

  describe 'workflow' do
    let(:reference) { create :any_reference }

    describe 'default state' do
      it "starts as 'none'" do
        expect(reference.none?).to eq true
        expect(reference.reviewing?).to eq false
        expect(reference.reviewed?).to eq false

        expect(reference.can_start_reviewing?).to eq true
        expect(reference.can_finish_reviewing?).to eq false
        expect(reference.can_restart_reviewing?).to eq false
      end
    end

    describe '#start_reviewing!' do
      it "none transitions to start" do
        expect { reference.start_reviewing! }.to change { reference.reviewing? }.to(true)

        expect(reference.can_start_reviewing?).to eq false
        expect(reference.can_finish_reviewing?).to eq true
        expect(reference.can_restart_reviewing?).to eq false
      end
    end

    describe '#finish_reviewing!' do
      before do
        reference.start_reviewing!
      end

      it "start transitions to finish" do
        expect { reference.finish_reviewing! }.to change { reference.reviewed? }.to(true)

        expect(reference.can_start_reviewing?).to eq false
        expect(reference.can_finish_reviewing?).to eq false
        expect(reference.can_restart_reviewing?).to eq true
      end
    end

    describe '#restart_reviewing!' do
      before do
        reference.start_reviewing!
        reference.finish_reviewing!
      end

      it "reviewed can transition back to reviewing" do
        expect { reference.restart_reviewing! }.to change { reference.reviewing? }.to(true)

        expect(reference.can_start_reviewing?).to eq false
        expect(reference.can_finish_reviewing?).to eq true
        expect(reference.can_restart_reviewing?).to eq false
      end
    end
  end

  describe '#citation_year_with_stated_year' do
    context 'when reference does not have a `stated_year`' do
      let(:reference) { create :any_reference, citation_year: "2000a" }

      specify { expect(reference.citation_year_with_stated_year).to eq '2000a' }
    end

    context 'when reference has a `stated_year`' do
      let(:reference) { create :any_reference, citation_year: "2000a", stated_year: "2001" }

      specify { expect(reference.citation_year_with_stated_year).to eq '2000a ("2001")' }
    end
  end

  describe "#author_names_string" do
    let(:ward) { create :author_name, name: 'Ward, P.S.' }
    let(:fisher) { create :author_name, name: 'Fisher, B.L.' }

    context "when reference has one author name" do
      let(:reference) { create :any_reference, author_names: [fisher] }

      it 'returns the author name' do
        expect(reference.author_names_string).to eq 'Fisher, B.L.'
      end
    end

    context "when reference has more than one author name" do
      let(:reference) { create :any_reference, author_names: [fisher, ward] }

      it "separates multiple author names with semicolons" do
        expect(reference.author_names_string).to eq 'Fisher, B.L.; Ward, P.S.'
      end
    end

    describe "updating author names" do
      context "when an author name is added" do
        let(:reference) { create :any_reference, author_names: [fisher] }

        it "updates its `author_names_string`" do
          reference.author_names << ward
          expect(reference.author_names_string).to eq 'Fisher, B.L.; Ward, P.S.'
        end

        it "maintains the order in which they were added" do
          wilden = create :author_name, name: 'Wilden'
          reference.author_names << wilden
          reference.author_names << ward

          expect(reference.author_names_string).to eq 'Fisher, B.L.; Wilden; Ward, P.S.'
        end
      end

      context "when an author_name is removed" do
        let(:reference) { create :any_reference, author_names: [fisher, ward] }

        it "updates its `author_names_string`" do
          expect { reference.author_names.delete(ward) }.
            to change { reference.reload.author_names_string }.
            from('Fisher, B.L.; Ward, P.S.').to('Fisher, B.L.')
        end
      end

      context "when an author name is changed" do
        let(:reference) { create :any_reference, author_names: [ward] }

        it "updates its `author_names_string`" do
          expect { ward.update!(name: 'Fisher') }.
            to change { reference.reload.author_names_string }.
            from('Ward, P.S.').to('Fisher')
        end
      end
    end
  end

  describe "#author_names_string_with_suffix" do
    context "when reference has a `author_names_suffix`" do
      let(:reference) do
        fisher = create :author_name, name: 'Fisher, B.L.'
        create :any_reference, author_names: [fisher], author_names_suffix: '(ed.)'
      end

      it "includes the `author_names_suffix` after the author names" do
        expect(reference.author_names_string_with_suffix).to eq 'Fisher, B.L. (ed.)'
      end
    end
  end
end
