PaperTrail::Rails::Engine.eager_load!

module PaperTrail
  class Version < ::ActiveRecord::Base
    attr_accessible :change_id

    def user
      User.find(whodunnit) if whodunnit
    end
  end
end
