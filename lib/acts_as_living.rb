# frozen_string_literal: true

require 'active_support'

require 'acts_as_living/version'
require 'acts_as_living/acts_as_living'
require 'acts_as_living/methods_definer'
require 'acts_as_living/enum_definer'
require 'acts_as_living/callbacks_definer'
require 'acts_as_living/scopes_definer'
require 'acts_as_living/validations_definer'

module ActsAsLiving
  extend ActiveSupport::Autoload
end

require 'acts_as_living/railtie' if defined?(Rails)
