# coding: UTF-8
require 'spec_helper'

describe CatalogHelper do

  describe "search selector" do
    it "should return the HTML for the selector with a default selected" do
      expect(helper.search_selector(nil)).to eq(
          %{<select name=\"st\" id=\"st\"><option value=\"m\">matching</option>\n<option selected=\"selected\" value=\"bw\">beginning with</option>\n<option value=\"c\">containing</option></select>}
      )
    end
    it "should return the HTML for the selector with the specified one selected" do
      expect(helper.search_selector('c')).to eq(
          %{<select name=\"st\" id=\"st\"><option value=\"m\">matching</option>\n<option value=\"bw\">beginning with</option>\n<option selected=\"selected\" value=\"c\">containing</option></select>}
      )
    end
  end

  describe "Delegation to Formatters::CatalogFormatter" do
    it "status labels" do
      expect(Formatters::CatalogFormatter).to receive :status_labels
      helper.status_labels
    end
    it "format statistics" do
      expect(Formatters::CatalogFormatter).to receive(:format_statistics).with(1, :include_invalid => true)
      helper.format_statistics 1, true
    end
  end

  describe "Hide link" do
    it "should create a link to the hide tribes action with all the current parameters" do
      taxon = FactoryGirl.create :genus
      expect(helper.hide_link('tribes', taxon, {})).to eq('<a href="/catalog/hide_tribes">hide</a>')
    end
  end

  describe "Show child link" do
    it "should create a link to the show action" do
      taxon = FactoryGirl.create :genus
      expect(helper.show_child_link('tribes', taxon, {})).to eq(%{<a href="/catalog/show_tribes">show tribes</a>})
    end
  end

  describe "Delegation to Formatters::CatalogFormatter" do
    it "status labels" do
      expect(Formatters::CatalogFormatter).to receive :status_labels
      helper.status_labels
    end
    it "format statistics" do
      expect(Formatters::CatalogFormatter).to receive(:format_statistics).with(1, include_invalid: true)
      helper.format_statistics 1, true
    end
  end

  describe "Index column link" do
    it "should work" do
      expect(helper.index_column_link(:subfamily, 'none', 'none', nil)).to eq('<a class="valid selected" href="/catalog?child=none">(no subfamily)</a>')
    end
  end

  describe "array snaking" do
    it "should handle []" do
      expect(snake([], 1)).to eq([])
    end
    it "should handle [1]" do
      expect(snake([1], 1)).to eq([[1]])
    end

    it "should handle [1,2,3,4]" do
      expect(snake([1,2,3,4], 2)).to eq([[1,3], [2,4]])
    end

    it "should handle empty cells" do
      expect(snake([1,2,3,4,5], 2)).to eq([[1,4], [2,5], [3,nil]])
    end

    it "should put all nil padding items at the end" do
      array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
      manually_snaked = [
        [1, 4, 6, 8, 10],
        [2, 5, 7, 9, 11],
        [3, nil, nil, nil, nil]
      ]
      expect(snake(array, 5)).to eq(manually_snaked)
    end
  end

end
