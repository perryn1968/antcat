class DatabaseScriptDecorator < Draper::Decorator
  GITHUB_MASTER_URL = "https://github.com/calacademy-research/antcat/blob/master"

  delegate :tags, :topic_areas, :filename_without_extension, :cache_key

  # Decorate class because we want to be able to call this without a script.
  def self.format_tags tags
    tags.map do |tag|
      helpers.content_tag :span, class: tag_css_class(tag) do
        helpers.raw tag.html_safe
      end
    end.join(" ").html_safe
  end

  def cached_when
    if cached_at
      "#{helpers.time_ago_in_words cached_at} ago"
    else
      helpers.dash
    end
  end

  def format_tags
    self.class.format_tags tags
  end

  def format_topic_areas
    topic_areas.join(", ").capitalize
  end

  def github_url
    scripts_path = DatabaseScript::SCRIPTS_DIR
    "#{GITHUB_MASTER_URL}/#{scripts_path}/#{filename_without_extension}.rb"
  end

  private
    def self.tag_css_class tag
      case tag
      when DatabaseScript::SLOW_TAG      then "warning-label"
      when DatabaseScript::VERY_SLOW_TAG then "warning-label"
      when DatabaseScript::NEW_TAG       then "label"
      when DatabaseScript::CSV_TAG       then "pretty-label"
      else                                    "white-label"
      end
    end
    private_class_method :tag_css_class

    def cached_at
      entry = Rails.cache.send :read_entry, cache_key, {}
      at = entry.instance_variable_get(:@created_at)
      Time.at(at) if at
    end
end