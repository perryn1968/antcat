module RefactorTaxonFactoriesHelpers
  # Mimics `TaxaController#build_new_taxon` to avoid interference from the factories.
  def build_new_taxon rank
    taxon_class = "#{rank}".titlecase.constantize

    taxon = taxon_class.new
    taxon.build_name
    taxon.build_type_name
    taxon.build_protonym
    taxon.protonym.build_name
    taxon.protonym.build_authorship
    taxon
  end

  # New set of light factories because FactoryBot does too much and some factories are bugged.
  # TODO refactor and merge.
  def build_minimal_family
    name = FamilyName.new name: "Formicidae"
    protonym = Protonym.first || minimal_protonym
    Family.new name: name, protonym: protonym, status: Status::VALID
  end

  def minimal_family
    build_minimal_family.tap &:save
  end

  def minimal_subfamily
    name = SubfamilyName.new name: "Minimalinae"
    protonym = Protonym.first || minimal_protonym
    Subfamily.new(name: name, protonym: protonym, status: Status::VALID).tap &:save
  end

  def minimal_protonym
    reference = UnknownReference.new citation: "book", citation_year: 2000, title: "Ants plz"
    citation = Citation.new reference: reference
    name = Name.new name: "name"

    Protonym.new name: name, authorship: citation
  end

  def an_old_taxon
    taxon = minimal_family
    taxon.taxon_state.update_columns review_state: TaxonState::OLD
    taxon.reload
    taxon
  end
end
