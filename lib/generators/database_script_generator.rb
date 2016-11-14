class DatabaseScriptGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("../templates", __FILE__)

  desc "Create example database script"
  def create_script_file
    template "database_script.rb", target_file
  end

  private
    def target_file
      scripts_path = DatabaseScripts::DatabaseScript::SCRIPTS_PATH
      File.join scripts_path, class_path, "#{file_name}.rb"
    end
end
