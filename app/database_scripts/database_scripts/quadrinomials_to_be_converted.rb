module DatabaseScripts
  class QuadrinomialsToBeConverted < DatabaseScript
    def results
      Subspecies.joins(:name).where("(LENGTH(names.name) - LENGTH(REPLACE(names.name, ' ', '')) >= 3) ")
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :target_subspecies_name_string, :convertable?, :target_subspecies, :status, :target_subspecies_validation_issues

        t.rows do |taxon|
          name_string = taxon.name_cache
          target_subspecies_name_string = name_string.split[0..2].join(' ')
          target_subspecies_candiates = Subspecies.where(name_cache: target_subspecies_name_string)

          convertable = target_subspecies_candiates.count == 1
          target_subspecies = target_subspecies_candiates.first

          [
            markdown_taxon_link(taxon),
            taxon.status,
            target_subspecies_name_string,
            ('Yes' if convertable),
            (target_subspecies.link_to_taxon if convertable),
            (target_subspecies.status if convertable),
            (format_failed_soft_validations(target_subspecies) if convertable && target_subspecies.soft_validations.failed?)
          ]
        end
      end
    end

    private

      def format_failed_soft_validations target_subspecies
        target_subspecies.soft_validations.failed.reject do |validation|
          validation.database_script.is_a?(DatabaseScripts::UnavailableUncategorizedTaxa) ||
            validation.database_script.is_a?(DatabaseScripts::NonValidTaxaWithACurrentValidTaxonThatIsNotValid)
        end.map(&:issue_description).join('<br><br>')
      end
  end
end

__END__

category: Script (pending)
tags: [slow]

description: >
  To be converted by script.


  **TODO:**


  * *Done* - Step 1) Convert batch 1: Quadrinomials where a `Subspecies` with the target name exists

  * *Done* - Step 2) Recreate missing subspecies by script

  * *Done* - Step 3) Cleanup recreated subspecies (see "Target subspecies soft validation issues")

  * Step 4) Convert batch 2: Quadrinomials where a `Subspecies` with the target name exists after missing subspecies were recreated


  Issues: %github714, %github819

related_scripts:
  - Quadrinomials
  - QuadrinomialsToBeConverted