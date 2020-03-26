# TODO: Implement pagination for lists inside scripts.

class DatabaseScriptsController < ApplicationController
  FLUSH_QUERY_CACHE_DEBUG = false

  before_action :authenticate_user!

  def index
    @grouped_database_scripts = DatabaseScript.all.group_by do |script|
      if DatabaseScript::REGRESSION_TEST_TAG.in? script.tags
        [2, 'Regression tests, to check periodically']
      elsif DatabaseScript::LIST_TAG.in? script.tags
        [3, 'Lists']
      else
        [1, 'Main scripts']
      end
    end.sort_by { |(sort_order, _title), _scripts| sort_order }
    @check_if_empty = params[:check_if_empty]
  end

  def show
    # :nocov:
    if FLUSH_QUERY_CACHE_DEBUG && Rails.env.development?
      ActiveRecord::Base.connection.execute('FLUSH QUERY CACHE;')
    end
    # :nocov:

    @database_script = find_database_script

    respond_to do |format|
      format.html do
        @rendered, @render_duration = timed_render
      end

      format.csv do
        send_data @database_script.to_csv, filename: csv_filename
      end
    end
  end

  private

    def find_database_script
      DatabaseScript.new_from_filename_without_extension params[:id]
    rescue DatabaseScript::ScriptNotFound
      raise ActionController::RoutingError, "Not Found"
    end

    def timed_render
      start = Time.current
      rendered = @database_script.render
      render_duration = Time.current - start

      [rendered, render_duration]
    end

    def csv_filename
      "antcat_org__#{@database_script.filename_without_extension}__#{Time.zone.today}.csv"
    end
end
