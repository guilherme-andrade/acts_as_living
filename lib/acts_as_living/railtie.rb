# frozen_string_literal: true

require 'active_support'
require 'rails/railtie'

module ActsAsLiving
  class Railtie < Rails::Railtie
    config.to_prepare do
      ActiveSupport.on_load(:active_record) do
        include ActsAsLiving::ActsAsLiving
      end
    end

    rake_tasks do
      load 'tasks/acts_as_living.rake'
    end
  end
end
