# All `Name` subclasses are for taxa; `AuthorName`s are used for references.
# TODO: Validate presence/absence of spaces in names/epithet/epithets.

class Name < ApplicationRecord
  include RevisionsCanBeCompared
  include Trackable

  # TODO: See how we can make use of this (originally added for  debugging/dev/docs reasons only).
  # Two or more words:
  #   `SubgenusName`
  #   `SpeciesName`
  #   `SubspeciesName`
  SINGLE_WORD_NAMES = [
    'FamilyName',
    'FamilyOrSubfamilyName', # TODO: Split into `FamilyName` and `SubfamilyName` and remove.
    'SubfamilyName',
    'TribeName',
    'SubtribeName',
    'GenusName'
  ]

  has_many :protonyms, dependent: :restrict_with_error
  has_many :taxa, class_name: 'Taxon', dependent: :restrict_with_error

  validates :name, :epithet, presence: true
  validate :ensure_epithet_in_name

  after_save :set_taxon_caches

  scope :single_word_names, -> { where(type: SINGLE_WORD_NAMES) }

  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
  strip_attributes replace_newlines: true
  trackable parameters: proc { { name_html: name_html } }

  # TODO rename to avoid confusing this with [Rails'] dynamic finder methods.
  def self.find_by_name string
    Name.joins("LEFT JOIN taxa ON (taxa.name_id = names.id)").readonly(false).
      where(name: string).order('taxa.id DESC').order(:name).first
  end

  def rank
    self.class.name.gsub(/Name$/, "").underscore
  end

  def name_html
    name
  end

  def epithet_html
    epithet
  end

  def name_with_fossil_html fossil
    "#{dagger_html if fossil}#{name_html}".html_safe
  end

  def epithet_with_fossil_html fossil
    "#{dagger_html if fossil}#{epithet_html}".html_safe
  end

  def dagger_html
    '&dagger;'.html_safe
  end

  def what_links_here
    Names::WhatLinksHere[self]
  end

  def orphaned?
    !(taxa.exists? || protonyms.exists?)
  end

  private

    def ensure_epithet_in_name
      return if name.blank? || epithet.blank?
      return if name.include?(epithet)

      errors.add :epithet, "must occur in the full name"
      throw :abort
    end

    def words
      @words ||= name.split
    end

    def set_taxon_caches
      Taxon.where(name: self).update_all(name_cache: name, name_html_cache: name_html)
    end
end
