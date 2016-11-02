require 'spec_helper'

describe Tribe do
  let(:subfamily) { create :subfamily, name: create(:name, name: 'Myrmicinae')}
  let(:tribe) { create :tribe, name: create(:name, name: 'Attini'), subfamily: subfamily }

  it "can have a subfamily" do
    expect(tribe).to eq tribe # trigger FactoryGirl
    expect(Tribe.find_by_name('Attini').subfamily).to eq subfamily
  end

  it "can have genera, which are its children" do
    create :genus, name: create(:name, name: 'Acromyrmex'), tribe: tribe
    create :genus, name: create(:name, name: 'Atta'), tribe: tribe

    expect(tribe.genera.map(&:name).map(&:to_s)).to match_array ['Atta', 'Acromyrmex']
    expect(tribe.children).to eq tribe.genera
  end

  it "should have as its full name just its name" do
    expect(tribe.name.to_s).to eq 'Attini'
  end

  # TODO belongs to Name
  it "should have as its label, just its name" do
    expect(tribe.name.to_html).to eq 'Attini'
  end

  describe "#siblings" do
    it "returns itself and its subfamily's other tribes" do
      another_tribe = create :tribe, subfamily: subfamily
      expect(tribe.siblings).to match_array [tribe, another_tribe]
    end
  end

  describe "#statistics" do
    it "includes the number of genera" do
      create :genus, tribe: tribe
      expect(tribe.statistics).to eq extant: { genera: { 'valid' => 1 } }
    end
  end

  describe "#update_parent" do
    let(:new_subfamily) {  create :subfamily }

    it "assigns the subfamily when parent is a tribe" do
      tribe.update_parent new_subfamily
      expect(tribe.subfamily).to eq new_subfamily
    end

    it "assigns the subfamily of its descendants" do
      genus = create_genus tribe: tribe
      species = create_species genus: genus
      create_subspecies species: species, genus: genus

      # test the initial subfamilies
      expect(tribe.subfamily).to eq subfamily
      expect(tribe.genera.first.subfamily).to eq subfamily
      expect(tribe.genera.first.species.first.subfamily).to eq subfamily
      expect(tribe.genera.first.subspecies.first.subfamily).to eq subfamily

      # test the updated subfamilies
      tribe.update_parent new_subfamily
      expect(tribe.subfamily).to eq new_subfamily
      expect(tribe.genera.first.subfamily).to eq new_subfamily
      expect(tribe.genera.first.species.first.subfamily).to eq new_subfamily
      expect(tribe.genera.first.subspecies.first.subfamily).to eq new_subfamily
    end
  end
end
