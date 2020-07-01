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
      stages = @stage_keys.map.with_index(&method(:to_enum_map)).to_h
      stages.merge(@death => @spread * -1)
    end

    def to_enum_map(stage, index)
      [stage, index * @spread]
    end
  end
end
