module Journals
  class AutocompletesController < ApplicationController
    def show
      search_query = params[:term] || '' # TODO: Standardize all "q/qq/query/term".

      respond_to do |format|
        format.json do
          render json: Autocomplete::AutocompleteJournals[search_query].pluck(:name)
        end
      end
    end
  end
end
