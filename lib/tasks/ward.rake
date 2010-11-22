desc "Import Ward's HTML files into References"
task :import_ward => [:get_ward, :export_ward]

desc "Read Ward's HTML files"
task :get_ward => :environment do
  WardReference.delete_all
  WardBibliography.new('data/ward/ANTBIB95.htm', true).import_file
  WardBibliography.new('data/ward/ANTBIB96.htm', true).import_file
end

desc "Export Ward's references into References"
task :export_ward => :environment do
  Place.delete_all :verified => nil
  Reference.delete_all
  AuthorName.delete_all :verified => nil
  ReferenceAuthorName.delete_all
  Publisher.delete_all
  Journal.delete_all
  WardReference.export true
  Rake::Task["sunspot:solr:reindex"].invoke
end

desc "Fix author names with missing space after period"
task :fix_author_names => :environment do
  AuthorName.fix_missing_spaces true
end
