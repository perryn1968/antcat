require 'spec_helper'

describe Reference do
  # Throw in a MissingReference to make sure it's not returned.
  before { create :missing_reference }

  describe ".do_search, .perform_search, and .fulltext_search" do
    describe "Search parameters" do
      describe "Authors", search: true do
        it "returns an empty array if nothing is found for the author names" do
          expect(Reference.do_search(q: "author:Balou")).to be_empty
        end

        it "finds the reference for a given author_name if it exists" do
          bolton = create :author_name, name: "Bolton Barry"
          reference = create :book_reference, author_names: [bolton]
          create :book_reference, author_names: [create(:author_name, name: 'Fisher')]
          Sunspot.commit

          results = Reference.do_search q: "author:'#{bolton.name}'"
          expect(results).to eq [reference]
        end

        it "finds the references for all aliases of a given author_name", pending: true do
          pending "broke when search method was refactored"
          # TODO find out where this is used
          bolton = create :author
          bolton_barry = create :author_name, author: bolton, name: 'Bolton, Barry'
          bolton_b = create :author_name, author: bolton, name: 'Bolton, B.'
          bolton_barry_reference = create :book_reference, author_names: [bolton_barry], title: '1', pagination: '1'
          bolton_b_reference = create :book_reference, author_names: [bolton_b], title: '2', pagination: '2'

          expect(Reference.perform_search(authors: [bolton]).map(&:id)).to match(
            [bolton_b_reference, bolton_barry_reference].map(&:id)
          )
        end

        it "finds the reference with both author names, but not just one" do
          bolton = create :author_name, name: 'Bolton'
          fisher = create :author_name, name: 'Fisher'
          create :reference, author_names: [bolton]
          create :reference, author_names: [fisher]
          bolton_fisher_reference = create :reference, author_names: [bolton, fisher]
          Sunspot.commit

          expect(Reference.do_search(q: 'author:"Bolton Fisher"')).to eq [bolton_fisher_reference]
        end
      end

      describe 'Fulltext', search: true do
        describe 'Notes' do
          it 'searches in public notes' do
            matching_reference = reference_factory author_name: 'Hölldobler', public_notes: 'abcdef'
            reference_factory author_name: 'Hölldobler', public_notes: 'fedcba' # unmatching_reference
            Sunspot.commit

            expect(Reference.do_search(q: 'abcdef')).to eq [matching_reference]
          end

          it 'searches in editor notes' do
            matching_reference = reference_factory author_name: 'Hölldobler', editor_notes: 'abcdef'
            reference_factory author_name: 'Hölldobler', editor_notes: 'fedcba' # unmatching_reference
            Sunspot.commit

            expect(Reference.do_search(q: 'abcdef')).to eq [matching_reference]
          end

          it 'searches in taxonomic notes' do
            matching_reference = reference_factory author_name: 'Hölldobler', taxonomic_notes: 'abcdef'
            reference_factory author_name: 'Hölldobler', taxonomic_notes: 'fedcba' # unmatching_reference
            Sunspot.commit

            expect(Reference.do_search(q: 'abcdef')).to eq [matching_reference]
          end
        end

        describe 'Author names', search: true do
          let!(:reference) { reference_factory author_name: 'Hölldobler' }
          before { Sunspot.commit }

          it 'handles diacritics in the search term' do
            expect(Reference.do_search(q: 'Hölldobler')).to eq [reference]
          end

          it 'substitutes diacritics with English letters' do
            expect(Reference.do_search(q: 'holldobler')).to eq [reference]
          end
        end

        describe 'Journal name', search: true do
          it 'searches journal names' do
            matching_reference = reference_factory author_name: 'Hölldobler',
              journal: create(:journal, name: 'Journal')
            reference_factory author_name: 'Hölldobler' # unmatching_reference
            Sunspot.commit

            expect(Reference.do_search(q: 'journal')).to eq [matching_reference]
          end
        end

        describe 'Publisher name', search: true do
          it 'searches publisher names' do
            matching_reference = reference_factory author_name: 'Hölldobler',
              publisher: create(:publisher, name: 'Publisher')
            reference_factory author_name: 'Hölldobler' # unmatching_reference
            Sunspot.commit

            expect(Reference.do_search(q: 'Publisher')).to eq [matching_reference]
          end
        end

        describe 'Citation (for Unknown references)', search: true do
          it 'searches in citations' do
            matching_reference = reference_factory author_name: 'Hölldobler', citation: 'Citation'
            unmatching_reference = reference_factory author_name: 'Hölldobler'
            Sunspot.commit

            expect(Reference.do_search(q: 'Citation')).to eq [matching_reference]
          end
        end

        describe 'Year', search: true do
          before do
            reference_factory author_name: 'Bolton', citation_year: '1994'
            reference_factory author_name: 'Bolton', citation_year: '1995'
            reference_factory author_name: 'Bolton', citation_year: '1996'
            reference_factory author_name: 'Bolton', citation_year: '1997'
            reference_factory author_name: 'Bolton', citation_year: '1998'
            Sunspot.commit
          end

          it "returns an empty array if nothing is found for year" do
            results = Reference.fulltext_search keywords: '', start_year: 1992, end_year: 1993
            expect(results).to be_empty
          end

          it "finds entries in between the start year and the end year (inclusive)" do
            results = Reference.fulltext_search keywords: '', start_year: 1995, end_year: 1996
            expect(results.map(&:year)).to match_array [1995, 1996]
          end

          it "finds references in the year of the end range, even if they have extra characters" do
            reference_factory author_name: 'Bolton', citation_year: '2004.'
            Sunspot.commit

            results = Reference.fulltext_search keywords: '', year: 2004
            expect(results.map(&:year)).to match_array [2004]
          end
        end

        describe "Year and fulltext", search: true do
          it "works" do
            atta2004 = create :book_reference, title: 'Atta', citation_year: '2004'
            atta2003 = create :book_reference, title: 'Atta', citation_year: '2003'
            formica2004 = create :book_reference, title: 'Formica', citation_year: '2003'
            Sunspot.commit

            expect(Reference.fulltext_search(keywords: 'atta', year: 2004)).to eq [atta2004]
          end
        end
      end
    end

    describe "Filtering", search: true do
      it "applies the :unknown :reference_type that's passed" do
        unknown = create :unknown_reference
        create :article_reference # known
        Sunspot.commit

        expect(Reference.fulltext_search(q: "bolton", reference_type: :unknown)).to eq [unknown]
      end

      it "applies the :nomissing :reference_type that's passed" do
        expect(MissingReference.count).to be > 0
        reference = create :article_reference
        Sunspot.commit
        expect(Reference.fulltext_search(q: 'bolton', reference_type: :nomissing)).to eq [reference]
      end

      it "applies the :nested :reference_type that's passed" do
        nested = create :nested_reference
        create :unknown_reference # unnested
        Sunspot.commit

        expect(Reference.fulltext_search(q: 'bolton', reference_type: :nested)).to eq [nested]
      end
    end

    describe "replacing some characters to make search work", search: true do
      it "handles this reference with asterixes and a hyphen" do
        title = '*Camponotus piceus* (Leach, 1825), decouverte Viroin-Hermeton'
        reference = create :article_reference, title: title
        Sunspot.commit

        results = Reference.fulltext_search title: title
        expect(results).to eq [reference]
      end
    end
  end

  describe ".solr_search", search: true do
    it "returns an empty array if nothing is found for author_name" do
      create :reference
      Sunspot.commit

      expect(Reference.solr_search { keywords 'foo' }.results).to be_empty
    end

    it "finds the reference for a given author_name if it exists" do
      reference = reference_factory author_name: 'Ward'
      reference_factory author_name: 'Fisher'
      Sunspot.commit

      expect(Reference.solr_search { keywords 'Ward' }.results).to eq [reference]
    end

    it "returns an empty array if nothing is found for a given year and author_name" do
      reference_factory author_name: 'Bolton', citation_year: '2010'
      reference_factory author_name: 'Bolton', citation_year: '1995'
      reference_factory author_name: 'Fisher', citation_year: '2011'
      reference_factory author_name: 'Fisher', citation_year: '1996'
      Sunspot.commit

      expect(Reference.solr_search {
        with(:year).between(2012..2013)
        keywords 'Fisher'
      }.results).to be_empty
    end

    it "returns the one reference for a given year and author_name" do
      reference_factory author_name: 'Bolton', citation_year: '2010'
      reference_factory author_name: 'Bolton', citation_year: '1995'
      reference_factory author_name: 'Fisher', citation_year: '2011'
      reference = reference_factory author_name: 'Fisher', citation_year: '1996'
      Sunspot.commit

      expect(Reference.solr_search {
        with(:year).between(1996..1996)
        keywords 'Fisher'
      }.results).to eq [reference]
    end

    it "searches citation years" do
      with_letter = reference_factory author_name: 'Bolton', citation_year: '2010b'
      reference_factory author_name: 'Bolton', citation_year: '2010'
      Sunspot.commit

      expect(Reference.solr_search {
        keywords '2010b'
      }.results).to eq [with_letter]
    end
  end

  describe ".do_search" do
    describe "Searching for text and/or years" do
      it "extracts the starting and ending years" do
        expect(Reference).to receive(:fulltext_search)
          .with hash_including(keywords: '', start_year: "1992", end_year: "1993")
        Reference.do_search q: 'year:1992-1993'
      end

      it "extracts the starting year" do
        expect(Reference).to receive(:fulltext_search)
          .with hash_including(keywords: '', year: "1992")
        Reference.do_search q: 'year:1992'
      end

      it "converts the query string", pending: true do
        pending "downcasing/transliteration removed valid search results"
        # TODO config solr
        expect(Reference).to receive(:fulltext_search)
          .with hash_including(keywords: 'andre')
        Reference.do_search q: 'André'
      end

      it "can distinguish between years and citation years" do
        expect(Reference).to receive(:fulltext_search)
          .with hash_including(keywords: '1970a', year: "1970")
        Reference.do_search q: '1970a year:1970'
      end
    end

    describe "Pagination on or off for different search types" do
      it "doesn't paginate EndNote format", pending: true do
        pending "not implemented like this any longer"
        expect(Reference).to receive(:fulltext_search).with hash_excluding(page: 1)
        Reference.do_search q: 'bolton', format: :endnote_export
      end

      it "paginates other formats" do
        expect(Reference).to receive(:fulltext_search).with hash_including(page: 1)
        Reference.do_search q: 'bolton'
      end
    end

    describe "Filtering unknown reference types" do
      context "when type:unknown is passed as the search term" do
        it "returns only references of type unknown" do
          expect(Reference).to receive(:fulltext_search)
            .with hash_including(keywords: 'Monroe', reference_type: :unknown)
          Reference.do_search q: 'Monroe type:unknown'
        end
      end
    end
  end
end

describe Reference do
  describe "#list_references" do
    before { create :missing_reference }

    it "returns all references" do
      reference = create :article_reference
      expect(Reference.list_references).to eq [reference]
    end

    describe "Sorting" do
      describe "Default sort order" do
        it "sorts by author_name plus year plus letter" do
          fisher1910b = reference_factory author_name: 'Fisher',
            citation_year: '1910b', fix_type: :article_reference
          wheeler1874 = reference_factory author_name: 'Wheeler',
            citation_year: '1874', fix_type: :article_reference
          fisher1910a = reference_factory author_name: 'Fisher',
            citation_year: '1910a', fix_type: :article_reference

          expect(Reference.list_references)
            .to eq [fisher1910a, fisher1910b, wheeler1874]
        end

        it "sorts by multiple author_names using their order in each reference" do
          a = reference_from_author_string 'Abdalla, F. C.; Cruz-Landim, C. da.'
          m = reference_from_author_string 'Mueller, U. G.; Mikheyev, A. S.; Abbot, P.'
          v = reference_from_author_string "Vinson, S. B.; MacKay, W. P.; Rebeles M.; A.; Arredondo B.; H. C.; Rodríguez R.; A. D.; González, D. A."

          expect(Reference.list_references).to eq [a, m, v]
        end

        def reference_from_author_string string
          author_names = AuthorName.import_author_names_string(string)[:author_names]
          create :article_reference, author_names: author_names
        end
      end
    end
  end

  describe "#extract_keyword_params" do
    it "doesn't modify the orginal search term" do
      q = "Bolton 2003"
      _ = Reference.extract_keyword_params q
      expect(q).to eq q
    end

    it "doesn't change the keywords unless keyword params are present" do
      q = "Bolton 2003"
      keyword_params = Reference.extract_keyword_params q
      expect(keyword_params[:keywords]).to eq q
    end

    it "modifies the keywords string after extraction" do
      keyword_params = Reference.extract_keyword_params "Bolton year:2003"
      expect(keyword_params[:keywords]).to eq "Bolton"
    end

    describe "year keywords" do
      it "extracts the year" do
        keyword_params = Reference.extract_keyword_params "Bolton year:2003"
        expect(keyword_params[:year]).to eq "2003"
      end

      it "extracts ranges of years" do
        keyword_params = Reference.extract_keyword_params "Bolton year:2003-2015"
        expect(keyword_params[:start_year]).to eq "2003"
        expect(keyword_params[:end_year]).to eq "2015"
      end
    end

    it "extracts reference types" do
      keyword_params = Reference.extract_keyword_params "Bolton type:nested year:2003"
      expect(keyword_params[:reference_type]).to eq :nested
    end

    it "extracts authors" do
      keyword_params = Reference.extract_keyword_params "Ants Book author:Bolton"
      expect(keyword_params[:author]).to eq "Bolton"
    end

    describe "author queries containing spaces" do
      it "handles double quotes" do
        keyword_params = Reference.extract_keyword_params 'Ants Book author:"Barry Bolton"'
        expect(keyword_params[:author]).to eq "Barry Bolton"
      end

      it "handles single quotes" do
        keyword_params = Reference.extract_keyword_params "Ants Book author:'Barry Bolton'"
        expect(keyword_params[:author]).to eq "Barry Bolton"
      end
    end

    describe "author queries not wrapped in quotes" do
      it "handles hyphens" do
        keyword_params = Reference.extract_keyword_params 'author:Barry-Bolton'
        expect(keyword_params[:author]).to eq "Barry-Bolton"
      end

      it "handles diacritics" do
        keyword_params = Reference.extract_keyword_params "author:Hölldobler"
        expect(keyword_params[:author]).to eq "Hölldobler"
      end

      it "doesn't break if more search term are added after the author keyword" do
        q = "author:Hölldobler random string"
        keyword_params = Reference.extract_keyword_params q
        expect(keyword_params[:author]).to eq "Hölldobler"
        expect(keyword_params[:keywords]).to eq "random string"
      end
    end

    it "handles multiple keyword params" do
      q = 'Ants Book author:"Barry Bolton" year:2003 type:missing'
      keyword_params = Reference.extract_keyword_params q
      expect(keyword_params[:author]).to eq "Barry Bolton"
      expect(keyword_params[:year]).to eq "2003"
      expect(keyword_params[:reference_type]).to eq :missing
      expect(keyword_params[:keywords]).to eq "Ants Book"
    end

    it "handles keyword params without a serach term" do
      keyword_params = Reference.extract_keyword_params 'year:2003'
      expect(keyword_params[:year]).to eq "2003"
      expect(keyword_params[:keywords]).to eq ""
    end

    it "ignores a single space after the colon after a keyword" do
      keyword_params = Reference.extract_keyword_params 'author: Wilson'
      expect(keyword_params[:author]).to eq "Wilson"
      expect(keyword_params[:keywords]).to eq ""
    end

    it "ignores capitalization of the keyword" do
      keyword_params = Reference.extract_keyword_params 'Author:Wilson'
      expect(keyword_params[:author]).to eq "Wilson"
      expect(keyword_params[:keywords]).to eq ""
    end
  end
end
