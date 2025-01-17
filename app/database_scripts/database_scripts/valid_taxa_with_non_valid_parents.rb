# frozen_string_literal: true

module DatabaseScripts
  class ValidTaxaWithNonValidParents < DatabaseScript
    def self.record_in_results? taxon
      instance = new

      case taxon
      when Tribe
        instance.tribe_results.where(id: taxon.id).exists?
      when Subtribe
        instance.subtribe_results.where(id: taxon.id).exists?
      when Genus
        instance.genus_subfamily_results.where(id: taxon.id).exists? ||
          instance.genus_tribe_results.where(id: taxon.id).exists?
      when Subgenus
        instance.subgenus_results.where(id: taxon.id).exists?
      when Species
        instance.species_genus_results.where(id: taxon.id).exists? ||
          instance.species_subgenus_results.where(id: taxon.id).exists?
      when Subspecies
        instance.subspecies_results.where(id: taxon.id).exists?
      when Infrasubspecies
        instance.infrasubspecies_results.where(id: taxon.id).exists?
      end
    end

    def empty?
      !(
        tribe_results.exists? ||
        subtribe_results.exists? ||
        genus_subfamily_results.exists? ||
        genus_tribe_results.exists? ||
        subgenus_results.exists? ||
        species_genus_results.exists? ||
        species_subgenus_results.exists? ||
        subspecies_results.exists? ||
        infrasubspecies_results.exists?
      )
    end

    def tribe_results
      Tribe.valid.joins(:subfamily).where.not(subfamilies_taxa: { status: Status::VALID })
    end

    def subtribe_results
      Subtribe.valid.joins(:tribe).where.not(tribes_taxa: { status: Status::VALID })
    end

    def genus_subfamily_results
      Genus.valid.joins(:subfamily).where.not(subfamilies_taxa: { status: Status::VALID })
    end

    def genus_tribe_results
      Genus.valid.joins(:tribe).where.not(tribes_taxa: { status: Status::VALID })
    end

    def subgenus_results
      Subgenus.valid.joins(:genus).where.not(genera_taxa: { status: Status::VALID })
    end

    def species_genus_results
      Species.valid.joins(:genus).where.not(genera_taxa: { status: Status::VALID })
    end

    def species_subgenus_results
      Species.valid.joins(:subgenus).where.not(subgenera_taxa: { status: Status::VALID })
    end

    def subspecies_results
      Subspecies.valid.joins(:species).where.not(species_taxa: { status: Status::VALID })
    end

    def infrasubspecies_results
      Infrasubspecies.valid.joins(:subspecies).where.not(subspecies_taxa: { status: Status::VALID })
    end

    def render
      as_table do |t|
        t.header 'Tribe', 'Tribe status', 'Subfamily', 'Subfamily status'

        t.rows(tribe_results) do |tribe|
          [
            taxon_link(tribe),
            tribe.status,
            taxon_link(tribe.subfamily),
            tribe.subfamily.status
          ]
        end
      end <<
        as_table do |t|
          t.header 'Subtribe', 'Subtribe status', 'Tribe', 'Tribe status'

          t.rows(subtribe_results) do |subtribe|
            [
              taxon_link(subtribe),
              subtribe.status,
              taxon_link(subtribe.tribe),
              subtribe.tribe.status
            ]
          end
        end <<
        as_table do |t|
          t.header 'Genus', 'Genus status', 'Subfamily', 'Subfamily status'

          t.rows(genus_subfamily_results) do |genus|
            [
              taxon_link(genus),
              genus.status,
              taxon_link(genus.subfamily),
              genus.subfamily.status
            ]
          end
        end <<
        as_table do |t|
          t.header 'Genus', 'Genus status', 'Tribe', 'Tribe status'

          t.rows(genus_tribe_results) do |genus|
            [
              taxon_link(genus),
              genus.status,
              taxon_link(genus.tribe),
              genus.tribe.status
            ]
          end
        end <<
        as_table do |t|
          t.header 'Subgenus', 'Subgenus status', 'Genus', 'Genus status'

          t.rows(subgenus_results) do |subgenus|
            [
              taxon_link(subgenus),
              subgenus.status,
              taxon_link(subgenus.genus),
              subgenus.genus.status
            ]
          end
        end <<
        as_table do |t|
          t.header 'Species', 'Species status', 'Genus', 'Genus status'

          t.rows(species_genus_results) do |species|
            [
              taxon_link(species),
              species.status,
              taxon_link(species.genus),
              species.genus.status
            ]
          end
        end <<
        as_table do |t|
          t.header 'Species', 'Species status', 'Subgenus', 'Subgenus status'

          t.rows(species_subgenus_results) do |species|
            [
              taxon_link(species),
              species.status,
              taxon_link(species.subgenus),
              species.subgenus.status
            ]
          end
        end <<
        as_table do |t|
          t.header 'Subspecies', 'Subspecies status', 'Species', 'Species status'

          t.rows(subspecies_results) do |subspecies|
            [
              taxon_link(subspecies),
              subspecies.status,
              taxon_link(subspecies.species),
              subspecies.species.status
            ]
          end
        end <<
        as_table do |t|
          t.header 'Infrasubspecies', 'Infrasubspecies status', 'Subspecies', 'Subspecies status'

          t.rows(infrasubspecies_results) do |infrasubspecies|
            [
              taxon_link(infrasubspecies),
              infrasubspecies.status,
              taxon_link(infrasubspecies.subspecies),
              infrasubspecies.subspecies.status
            ]
          end
        end
    end
  end
end

__END__

title: Valid taxa with non-valid parents

section: regression-test
tags: [taxa, disagreeing-data, updated!]

issue_description: This taxon is valid, but its parent is not.

description: >

related_scripts:
  - ExtantTaxaInFossilGenera
  - ValidTaxaWithNonValidParents
