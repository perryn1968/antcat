# frozen_string_literal: true

class RemoveFossilFromTaxa < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :taxa, :fossil, :boolean, default: false, null: false
    end
  end
end
