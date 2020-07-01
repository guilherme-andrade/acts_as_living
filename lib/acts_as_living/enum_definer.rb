# frozen_string_literal: true

module ActsAsLiving::EnumDefiner
  def self.call(klass)
    klass.class_eval do
      extend ClassMethods

      enum @column => enum_options
    end
  end

  module ClassMethods
    def enum_options
      statuses = @status_keys.map.with_index(&method(:to_enum_map)).to_h
      statuses.merge(@death => @spread * -1)
    end

    def to_enum_map(status, index)
      [status, index * @spread]
    end
  end
end
