class TaxonDecorator::Header
  include Formatters::ItalicsHelper

  def initialize taxon
    @taxon = taxon
  end

  # This links the different parts of the binomial name. Only applicable to
  # species and below, since higher ranks consists of a single word.
  def link_each_epithet
    return @taxon.decorate.link_to_taxon unless @taxon.kind_of? SpeciesGroupTaxon
    return nonconforming_name_header_link(@taxon) if @taxon.name.nonconforming_name?

    string = genus_link_or_blank_string @taxon

    if @taxon.is_a? Species
      return string << header_link(@taxon, @taxon.name.epithet_html.html_safe)
    end

    species = @taxon.species
    if species
      string << header_link(species, species.name.epithet_html.html_safe)
      string << ' '.html_safe
      epithets_without_species = @taxon.name.epithets.split(' ')[1..-1].join ' '
      string << header_link(@taxon, italicize(epithets_without_species))
    else
      string << header_link(@taxon, italicize(taxon.name.epithets))
    end

    string
  end

  private
    # This name is a radical misspelling, or an obsolete name formulation.
    # Display literally, but link genus if there is one.
    def nonconforming_name_header_link taxon
      string = genus_link_or_blank_string taxon
      string << header_link(taxon, italicize(taxon.name.epithets))
    end

    def genus_link_or_blank_string taxon
      return "".html_safe unless taxon.genus

      # Link name of the genus, but add dagger per to taxon's fossil status.
      label = taxon.genus.name.to_html_with_fossil @taxon.fossil?
      taxon.genus.decorate.link_to_taxon_with_label label.html_safe << " "
    end

    def header_link taxon, label
      taxon.decorate.link_to_taxon_with_label label
    end
end
