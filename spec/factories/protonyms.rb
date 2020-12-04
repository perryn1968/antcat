# frozen_string_literal: true

FactoryBot.define do
  factory :protonym do
    transient do
      taxt_tag {}
      authorship_reference {}
    end

    authorship do
      if authorship_reference
        association :citation, reference: authorship_reference
      else
        association :citation
      end
    end

    genus_group_name

    # Rank-related.
    trait :family_group_name do
      association :name, factory: :family_name
    end

    trait :genus_group_name do
      association :name, factory: :genus_name
    end

    trait :species_group_name do
      association :name, factory: :species_name
    end

    # Fossil-related.
    trait :fossil do
      fossil { true }
    end

    trait :ichnotaxon do
      fossil
      ichnotaxon { true }
    end

    # Nomen attributes.
    trait :nomen_nudum do
      nomen_nudum { true }
    end

    # Misc.
    trait :uncertain_locality do
      uncertain_locality { true }
    end

    trait :with_type_name do
      type_name
    end

    trait :with_all_taxts do
      sequence(:etymology_taxt) { |n| "etymology_taxt #{n} #{taxt_tag}" }
      sequence(:primary_type_information_taxt) { |n| "primary_type_information_taxt #{n} #{taxt_tag}" }
      sequence(:secondary_type_information_taxt) { |n| "secondary_type_information_taxt #{n} #{taxt_tag}" }
      sequence(:type_notes_taxt) { |n| "type_notes_taxt #{n} #{taxt_tag}" }
      sequence(:notes_taxt) { |n| "notes_taxt #{n} #{taxt_tag}" }
    end
  end
end
