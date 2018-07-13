class JournalsController < ApplicationController
  before_action :authenticate_editor, except: [:index, :show, :autocomplete]
  before_action :set_journal, only: [:show, :edit, :update, :destroy]

  layout "references"

  def index
    @journals = Journal.order(:name).paginate(page: params[:page], per_page: 100)
  end

  def show
    @references = @journal.references
      .sorted_by_principal_author_last_name
      .includes_document
      .paginate(page: params[:page])
  end

  def new
    @journal = Journal.new
  end

  def edit
  end

  def create
    @journal = Journal.new journal_params
    if @journal.save
      flash[:notice] = "Successfully created journal."
      redirect_to @journal
    else
      render :new
    end
  end

  def update
    if @journal.update journal_params
      flash[:notice] = "Successfully updated journal."
      redirect_to @journal
    else
      render :edit
    end
  end

  def destroy
    if @journal.destroy
      redirect_to references_path, notice: "Journal was successfully deleted."
    else
      if @journal.errors.present?
        flash[:warning] = @journal.errors.full_messages.to_sentence
      end
      redirect_to @journal
    end
  end

  def autocomplete
    search_query = params[:term] || '' # TODO standardize all "q/qq/query/term".

    respond_to do |format|
      format.json { render json: Autocomplete::AutocompleteJournals[search_query] }
    end
  end

  # For at.js. We need the IDs, which isn't included in `#autocomplete`.
  # TODO see if we can merge this with `#autocomplete`.
  def linkable_autocomplete
    search_query = params[:q] || ''

    respond_to do |format|
      format.json do
        render json: Autocomplete::AutocompleteLinkableJournals[search_query]
      end
    end
  end

  private
    def set_journal
      @journal = Journal.find(params[:id])
    end

    def journal_params
      params.require(:journal).permit(:name)
    end
end
