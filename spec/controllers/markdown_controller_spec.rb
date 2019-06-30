require 'spec_helper'

describe MarkdownController do
  describe "POST preview" do
    let(:text) { "markdown" }

    it "calls `Markdowns::Render`" do
      expect(Markdowns::Render).to receive(:new).with(text).and_call_original
      post :preview, params: { text: text }
    end
  end
end