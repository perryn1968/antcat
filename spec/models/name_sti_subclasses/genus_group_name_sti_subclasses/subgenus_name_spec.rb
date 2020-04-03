# frozen_string_literal: true

require 'rails_helper'

describe SubgenusName do
  describe '#name=' do
    specify do
      name = described_class.new(name: 'Lasius (Austrolasius)')

      expect(name.name).to eq 'Lasius (Austrolasius)'
      expect(name.epithet).to eq 'Austrolasius'
    end
  end
end