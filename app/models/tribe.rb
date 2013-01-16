# coding: UTF-8
class Tribe < Taxon
  belongs_to :subfamily
  has_many :genera

  def self.import data
    transaction do
      attributes = {
        name:       Name.import(data),
        fossil:     data[:fossil] || false,
        status:     data[:status] || 'valid',
        protonym:   Protonym.import(data[:protonym]),
        subfamily:  data[:subfamily],
      }
      attributes.merge! get_type_attributes :type_genus, data
      senior = data.delete :synonym_of
      tribe = create! attributes
      tribe.import_synonyms senior
      tribe.import_history data[:history]
      tribe
    end
  end

  #########

  def children
    genera
  end

  def statistics
    get_statistics [:genera]
  end

  def siblings
    subfamily.tribes
  end

  def inspect
    string = super
    if subfamily
      string << ", #{subfamily.name} #{subfamily.id}"
      string << " #{subfamily.status}" if subfamily.invalid?
    end
    string
  end

end
