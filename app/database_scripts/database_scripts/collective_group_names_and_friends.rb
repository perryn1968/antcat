module DatabaseScripts
  class CollectiveGroupNamesAndFriends < DatabaseScript
    def results
      boolean_collective_group_names = Taxon.where(collective_group_name: true)
      boolean_as_current_valid_taxon = Taxon.where(current_valid_taxon: boolean_collective_group_names)
      boolean_as_species = Taxon.where(genus_id: boolean_collective_group_names)

      Taxon.where(
        id: boolean_collective_group_names + boolean_as_current_valid_taxon + boolean_as_species
      )
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :collective_group_name?
        t.rows do |taxon|
          [markdown_taxon_link(taxon), taxon.status, taxon.collective_group_name]
        end
      end
    end
  end
end

__END__

description: >
  `collective_group_name?` refers to the new parallel status.

tags: []
topic_areas: [catalog]