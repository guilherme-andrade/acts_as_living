# frozen_string_literal: true

require 'active_support'
require 'acts_as_living/version'
require 'acts_as_living/class_methods'
require 'acts_as_living/enum_definer'
require 'acts_as_living/callbacks_definer'
require 'acts_as_living/instance_methods_definer'
require 'acts_as_living/scopes_definer'
require 'acts_as_living/validations_definer'

module ActsAsLiving
  extend ActiveSupport::Autoload

  rake_tasks do
    load 'tasks/acts_as_living.rake'
  end
end

require 'acts_as_living/railtie' if defined?(Rails)
