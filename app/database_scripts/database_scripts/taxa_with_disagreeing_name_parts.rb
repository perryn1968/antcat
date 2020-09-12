# frozen_string_literal: true

module DatabaseScripts
  class TaxaWithDisagreeingNameParts < DatabaseScript
    def empty?
      !(
        species_genus_vs_genus_genus.exists? ||
        subspecies_species_vs_species_species.exists? ||
        infrasubspecies_genus_vs_species_genus.exists? ||
        infrasubspecies_species_vs_species_species.exists? ||
        infrasubspecies_subspecies_vs_subspecies_subspecies.exists?
      )
    end

    def species_genus_vs_genus_genus
      Species.joins(:name).joins(:genus).
        joins("JOIN names genus_names ON genus_names.id = genera_taxa.name_id").
        where("SUBSTRING_INDEX(names.name, ' ', 1) != genus_names.name")
    end

    def subspecies_species_vs_species_species
      Subspecies.joins(:name).joins(:species).
        joins("JOIN names species_names ON species_names.id = species_taxa.name_id").
        where(<<~SQL.squish)
          SUBSTRING_INDEX(SUBSTRING_INDEX(names.name, ' ', 2), ' ', -1) !=
          SUBSTRING_INDEX(SUBSTRING_INDEX(species_names.name, ' ', 2), ' ', -1)
        SQL
    end

    def infrasubspecies_genus_vs_species_genus
      Infrasubspecies.joins(:name).joins(:species).
        joins("JOIN names species_names ON species_names.id = species_taxa.name_id").
        where(<<~SQL.squish)
          SUBSTRING_INDEX(names.name, ' ', 1) !=
          SUBSTRING_INDEX(species_names.name, ' ', 1)
        SQL
    end

    def infrasubspecies_species_vs_species_species
      Infrasubspecies.joins(:name).joins(:species).
        joins("JOIN names species_names ON species_names.id = species_taxa.name_id").
        where(<<~SQL.squish)
          SUBSTRING_INDEX(SUBSTRING_INDEX(names.name, ' ', 2), ' ', -1) !=
          SUBSTRING_INDEX(SUBSTRING_INDEX(species_names.name, ' ', 2), ' ', -1)
        SQL
    end

    def infrasubspecies_subspecies_vs_subspecies_subspecies
      Infrasubspecies.joins(:name).joins(:subspecies).
        joins("JOIN names subspecies_names ON subspecies_names.id = subspecies_taxa.name_id").
        where(<<~SQL.squish)
          SUBSTRING_INDEX(SUBSTRING_INDEX(names.name, ' ', 2), ' ', -1) !=
          SUBSTRING_INDEX(SUBSTRING_INDEX(subspecies_names.name, ' ', 2), ' ', -1)
        SQL
    end

    def render
      render_table(species_genus_vs_genus_genus, "species", :genus_epithet, :genus) +
        render_table(subspecies_species_vs_species_species, "subspecies", :species_epithet, :species) +
        render_table(infrasubspecies_genus_vs_species_genus, "infrasubspecies", :genus_epithet, :species) +
        render_table(infrasubspecies_species_vs_species_species, "infrasubspecies", :species_epithet, :species) +
        render_table(infrasubspecies_subspecies_vs_subspecies_subspecies, "infrasubspecies", :subspecies_epithet, :subspecies)
    end

    def render_table table_results, disagreeing_rank, epithet_method, of_its_rank
      as_table do |t|
        humanized_epithet = epithet_method.to_s.humanize.downcase

        t.caption "#{humanized_epithet.upcase} mismatch: #{disagreeing_rank} vs. #{of_its_rank}"
        t.header 'Disagreeing taxon', '...', '...', '...', 'Disagrees with taxon'
        t.rows(table_results) do |taxon|
          disagreeing_name_part = taxon.name.public_send(epithet_method)

          disagrees_with_taxon = taxon.public_send(of_its_rank)
          disagrees_with_name_part = disagrees_with_taxon.name.public_send(epithet_method)

          [
            taxon_link(taxon) + '<br><br>',
            "#{humanized_epithet} of #{disagreeing_rank}" + '<br>' + bold_warning(disagreeing_name_part),
            "...does not match...<br><br>",
            "#{humanized_epithet} of its #{of_its_rank}" + '<br>' + bold_warning(disagrees_with_name_part),
            taxon_link(disagrees_with_taxon)
          ]
        end
      end
    end
  end
end

__END__

section: regression-test
category: Catalog
tags: []

issue_description:

description: >
  Revived from old scripts, see %dbscript:NowDeletedScripts.

related_scripts:
  - TaxaWithDisagreeingNameParts