class FeedbackController < ApplicationController
  include ActionView::Helpers::DateHelper
  include HasWhereFilters

  before_action :authenticate_superadmin, only: [:destroy]
  before_action :authenticate_editor, except: [:create]
  before_action :set_feedback, only: [:show, :destroy, :close, :reopen]

  invisible_captcha only: [:create], honeypot: :work_email, on_spam: :on_spam

  has_filters(
    open: {
      tag: :select_tag,
      options: -> { [["Open", 1], ["Closed", 0]] },
      prompt: "Status"
    }
  )

  # TODO probably remove `by_status_and_date` now that we have filters.
  def index
    @feedbacks = Feedback.by_status_and_date.filter(filter_params)
    @feedbacks = @feedbacks.paginate(page: params[:page], per_page: 10)
  end

  def show
    @new_comment = Comment.build_comment @feedback, current_user
  end

  def create
    @feedback = Feedback.new feedback_params
    @feedback.ip = request.remote_ip
    render_unprocessable and return if maybe_rate_throttle

    if current_user
      @feedback.user = current_user
      @feedback.name = current_user.name
      @feedback.email = current_user.email
    end

    respond_to do |format|
      if @feedback.save
        format.json do
          json = { feedback_success_callout: feedback_success_callout }
          render json: json, status: :created
        end
      else
        format.json { render_unprocessable }
      end
    end
  end

  def destroy
    @feedback.destroy
    redirect_to feedback_index_path, notice: "Feedback item was successfully deleted."
  end

  def close
    @feedback.close
    redirect_to @feedback, notice: "Successfully closed feedback item."
  end

  def reopen
    @feedback.reopen
    redirect_to @feedback, notice: "Successfully re-opened feedback item."
  end

  def autocomplete
    q = params[:q] || ''

    # See if we have an exact ID match.
    search_results = if q =~ /^\d+ ?$/
                       id_matches_q = Feedback.find_by id: q
                       [id_matches_q] if id_matches_q
                     end

    search_results ||= Feedback.where("id LIKE ?", "%#{q}%").order(id: :desc)

    respond_to do |format|
      format.json do
        results = search_results.map do |feedback|
          # Show less data on purpose for privacy reasons.
          { id: feedback.id,
            date: (feedback.created_at.strftime '%Y-%m-%d %H:%M'),
            status: (feedback.open? ? "open" : "closed") }
        end
        render json: results
      end
    end
  end

  private
    def set_feedback
      @feedback = Feedback.find params[:id]
    end

    def on_spam
      @feedback = Feedback.new feedback_params
      @feedback.errors.add :hmm, "you're not a bot are you? Feedback not sent. Email us?"
      render_unprocessable
    end

    # TODO be more generous. Throttling is only for combating spam.
    def maybe_rate_throttle
      return if current_user # Logged-in users are never throttled.

      timespan = 5.minutes.ago
      max_feedbacks_in_timespan = 3

      if @feedback.from_the_same_ip.recently_created(timespan)
          .count >= max_feedbacks_in_timespan

        @feedback.errors.add :rate_limited, <<-ERROR_MSG
          you have already posted #{max_feedbacks_in_timespan} feedbacks in the last
          #{time_ago_in_words Time.at(timespan)}. Thanks for that! Please wait for
          a few minutes while we are trying to figure out if you are a bot...
        ERROR_MSG
      end
    end

    def render_unprocessable
      render json: @feedback.errors, status: :unprocessable_entity
    end

    def feedback_success_callout
      render_to_string partial: "feedback_success_callout",
        locals: { feedback_id: @feedback.id }
    end

    def feedback_params
      params.require(:feedback).permit :comment, :name, :email, :user, :page
    end
end
