require 'spec_helper'

describe Name do

  it "should have a name" do
    Name.new(name:'Name').name.should == 'Name'
  end

  it "should not allow duplicates" do
    Name.create! name: 'Atta'
    Name.new(name: 'Atta').should_not be_valid
  end

  it "should format the fossil symbol" do
    SpeciesName.new(epithet_html: '<i>major</i>').epithet_with_fossil_html(true).should == '<i>&dagger;</i><i>major</i>'
    SpeciesName.new(epithet_html: '<i>major</i>').epithet_with_fossil_html(false).should == '<i>major</i>'
    GenusName.new(epithet_html: '<i>Atta</i>').epithet_with_fossil_html(true).should == '<i>&dagger;</i><i>Atta</i>'
    GenusName.new(epithet_html: '<i>Atta</i>').epithet_with_fossil_html(false).should == '<i>Atta</i>'
    SubfamilyName.new(epithet_html: 'Attanae').epithet_with_fossil_html(true).should == '&dagger;Attanae'
    SubfamilyName.new(epithet_html: 'Attanae').epithet_with_fossil_html(false).should == 'Attanae'

    SpeciesName.new(name_html: '<i>Atta major</i>').to_html_with_fossil(false).should == '<i>Atta major</i>'
    SpeciesName.new(name_html: '<i>Atta major</i>').to_html_with_fossil(true).should == '<i>&dagger;</i><i>Atta major</i>'
  end

  describe "Updating taxon cache" do
    before do
      @atta = create_name 'Atta'
      @atta.update_attribute :name_html, '<i>Atta</i>'
    end

    it "should set the name_cache and name_html_cache in the taxon when assigned" do
      taxon = create_genus 'Eciton'
      taxon.name_cache.should == 'Eciton'
      taxon.name_html_cache.should == '<i>Eciton</i>'

      taxon.name = @atta
      taxon.save!
      taxon.name_cache.should == 'Atta'
      taxon.name_html_cache.should == '<i>Atta</i>'
    end

    it "should change the cache when the contents of the name change" do
      taxon = create_genus name: @atta
      taxon.name_cache.should == 'Atta'
      taxon.name_html_cache.should == '<i>Atta</i>'
      @atta.update_attributes name: 'Betta', name_html: '<i>Betta</i>'
      taxon.reload
      taxon.name_cache.should == 'Betta'
      taxon.name_html_cache.should == '<i>Betta</i>'
    end

    it "should change the cache when a different name is assigned" do
      betta = create_name 'Betta'
      betta.update_attribute :name_html, '<i>Betta</i>'

      taxon = create_genus name: @atta
      taxon.update_attribute :name, betta
      taxon.name_cache.should == 'Betta'
      taxon.name_html_cache.should == '<i>Betta</i>'
    end

  end

  describe "Parsing" do
    it "should parse a genus name" do
      name = Name.parse('Atta')
      name.should be_kind_of GenusName
      name.name.should == 'Atta'
      name.name_html.should == '<i>Atta</i>'
      name.epithet.should == 'Atta'
      name.epithet_html.should == '<i>Atta</i>'
      name.protonym_html.should == '<i>Atta</i>'
    end
    it "should parse a species name" do
      name = Name.parse('Atta major')
      name.should be_kind_of SpeciesName
      name.name.should == 'Atta major'
      name.name_html.should == '<i>Atta major</i>'
      name.epithet.should == 'major'
      name.epithet_html.should == '<i>major</i>'
      name.protonym_html.should == '<i>major</i>'
    end
    describe "Parsing subspecies names" do
      it "should handle one with two epithets, no type" do
        name = Name.parse('Atta major minor')
        name.should be_kind_of SubspeciesName
        name.name.should == 'Atta major minor'
        name.name_html.should == '<i>Atta major minor</i>'
        name.epithet.should == 'minor'
        name.epithet_html.should == '<i>minor</i>'
        name.epithets.should == 'major minor'
        name.protonym_html.should == '<i>major minor</i>'
      end
      it "should handle one with two epithets, including a type" do
        name = Name.parse('Atta major var. minor')
        name.should be_kind_of SubspeciesName
        name.name.should == 'Atta major var. minor'
        name.name_html.should == '<i>Atta major var. minor</i>'
        name.epithet.should == 'minor'
        name.epithet_html.should == '<i>minor</i>'
        name.epithets.should == 'major var. minor'
        name.protonym_html.should == '<i>major var. minor</i>'
      end
    end

  end
end
