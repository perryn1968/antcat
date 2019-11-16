module DatabaseScripts
  class UnavailableUncategorizedTaxaTouchedByEditors < DatabaseScript
    def results
      Taxon.where(status: Status::UNAVAILABLE_UNCATEGORIZED).where(auto_generated: false)
    end
  end
end

__END__

description: >
  Taxa with the status `unavailable uncategorized`. We want to convert these to other statuses.

tags: []
topic_areas: [catalog]
related_scripts:
  - UnavailableUncategorizedTaxaTouchedByEditors
  - UnavailableUncategorizedTaxa