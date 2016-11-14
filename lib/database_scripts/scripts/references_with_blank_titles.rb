class DatabaseScripts::Scripts::ReferencesWithBlankTitles
  include DatabaseScripts::DatabaseScript

  def results
    Reference.where(title: ["", nil])
  end
end
