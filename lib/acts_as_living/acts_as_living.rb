
require 'active_support/concern'

module ActsAsLiving::ActsAsLiving
  extend ActiveSupport::Concern

  class_methods do
    def acts_as_living(keys, periods:, lock_on:, death:, spread:, column:)
      @stage_keys     = keys
      @periods        = periods
      @locked_stages  = lock_on
      @death          = death
      @spread         = spread
      @column         = column

      run_definers
    end

    def run_definers
      ActsAsLiving::MethodsDefiner.call(self)
      ActsAsLiving::EnumDefiner.call(self)
      ActsAsLiving::ScopesDefiner.call(self)
      ActsAsLiving::ValidationsDefiner.call(self)
    end
  end
end
