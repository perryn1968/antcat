module DatabaseScripts
  class EpiAndQuestionmarkTaxtTags < DatabaseScript
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    def results
      models_and_ids = Taxt.models_with_taxts.map { |tag, _| [tag, []] }.to_h

      Taxt.models_with_taxts.each_field do |field, model|
        ["epi", "?"].each do |tag|
          models_and_ids[model] += model.where("#{field} LIKE '%{#{tag} %'").pluck(:id)
        end
      end

      models_and_ids
    end

    def render
      as_table do |t|
        t.header :item_type, :item_id

        results.each do |model, ids|
          t.rows(ids) do |id|
            [ model, attempt_to_link_item(model.name, id) ]
          end
        end
      end
    end

    private
      def attempt_to_link_item item_type, item_id
        case item_type
        when "TaxonHistoryItem"
          link_to(item_id, taxon_history_item_path(item_id))
        when "ReferenceSection"
          link_to(item_id, reference_section_path(item_id))
        when "Taxon"
          link_to(item_id, catalog_path(item_id))
        when "Citation"
          taxon_id = Citation.find(item_id).protonym.taxon.id
          "#{item_id} " + link_to("(Taxon #{taxon_id})", catalog_path(taxon_id))
        else
          "#{item_type} (#{item_id})"
        end
      end
  end
end

__END__
description: >
  This page lists all `epi` and `?` taxt tags (eg `{epi cinerascens}` and `{? Santschi, 1914d: 315}`).


  As far as I can tell, support for these types of tags were never fully implemented,
  so let's see what we want to do with these.


  Click on the links to see where they are used. If `Item type` says `Taxon`, the taxt tag is contained
   in either `headline_notes_taxt`, `type_taxt` or `genus_species_header_notes_taxt` of that taxon.
  If it says `Citation`, the taxt is stored in the `notes_taxt` column of that citation;
  since it's not possible no link citations, the taxon which's protonym references that citation.
topic_areas: [taxt]
