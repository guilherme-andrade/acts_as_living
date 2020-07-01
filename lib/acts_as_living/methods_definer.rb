# frozen_string_literal: true

module ActsAsLiving::MethodsDefiner
  def self.call(klass)
    klass.class_eval do
      extend ClassMethods
      include InstanceMethods

      @periods.each(&method(:define_period_queries))
      @stage_keys.each(&method(:define_stage_queries))
    end
  end

  module InstanceMethods
    def stage_after(stage)
      self.class.stage_after(stage)
    end

    def stages
      self.class.stages
    end

    def stage_before(stage)
      self.class.stage_before(stage)
    end

    def to_next_stage
      update(stage: next_stage)
    end

    def to_next_stage!
      update!(stage: next_stage)
    end

    def next_stage
      stage_after(stage) if stage
    end

    def to_previous_stage
      update(stage: previous_stage)
    end

    def to_previous_stage!
      update!(stage: previous_stage)
    end

    def previous_stage
      stage_before(stage)
    end

    def final_stage?
      self.class.final_stage?(stage)
    end

    def initial_stage?
      self.class.initial_stage?(stage)
    end

    def dead_stage?
      self.class.dead_stage == stage
    end

    def dead_or_finalized?
      dead_stage? || final_stage?
    end

    def klass_periods_with_ranges
      self.class.periods_with_ranges
    end

    def klass_periods_for(stage)
      self.class.periods_for(stage)
    end

    def klass_stages
      self.class.stages
    end

    def locked?(&block)
      return unless block

      @locked_on.to_set.intersect? [stage, stage_was].to_set
    end

    def periods
      klass_periods_for(stage)
    end

    def period_changed?
      klass_periods_for(stage) != klass_periods_for(stage_was)
    end

    def periods_started
      klass_periods_for(stage) - klass_periods_for(stage_was)
    end

    def periods_ended
      klass_periods_for(stage_was) - klass_periods_for(stage)
    end
  end

  module ClassMethods
    def alive_stages
      stages.except(@death).keys
    end

    def stage_keys
      stages.keys
    end

    def stages_after(stage)
      return [] if final_stage?(stage)

      stages[stage_after(stage)..]
    end

    def stages_before(stage)
      return [] if initial_stage?(stage)

      index = stage_keys.find_index(stage)
      stage_keys[0...index]
    end

    def stage_after(stage)
      return if final_stage?(stage)

      index = stage_keys.find_index(stage)
      stage_keys[index + 1]
    end

    def stage_before(stage)
      return if initial_stage?(stage)

      index = stage_keys.find_index(stage)
      stage_keys[index - 1]
    end

    def final_stage
      stage_keys.last
    end

    def final_stage?(stage)
      final_stage == stage
    end

    def initial_stage
      stages.key(0)
    end

    def dead_stage
      @death
    end

    def initial_stage?(stage)
      initial_stage == stage
    end

    def periods_with_ranges
      @periods.map(&method(:to_period_with_range)).to_h
    end

    def to_period_with_range(period, delimiter)
      [period, (stages[delimiter.first]..stages[delimiter.last])]
    end

    def periods
      @periods
    end

    def periods_for(stage)
      periods_with_ranges.keys.select do |period|
        periods_with_ranges[period].include? stages[stage]
      end
    end

    def define_period_queries(period, delimiters)
      define_method("#{period}?") do
        if delimiters.length == 1
          klass_stages[stage] == klass_stages[delimiters]
        else
          klass_stages[stage] >= klass_stages[delimiters.first] &&
            klass_stages[stage] <= klass_stages[delimiters.second]
        end
      end

      define_method("pre_#{period}?") do
        klass_stages[stage] < klass_stages[delimiters.first] unless cancelled?
      end

      define_method("past_#{period}?") do
        klass_stages[stage] > klass_stages[delimiters.last] || cancelled?
      end
    end

    def define_stage_queries(stage_key)
      define_method("stage_changed_to_#{stage_key}?") do
        stage_changed? && stage_was == stage_key
      end

      define_method("stage_saved_to_#{stage_key}?") do
        saved_change_to_stage? && stage == stage_key
      end

      define_method("pre_#{stage_key}?") do
        klass_stages[stage] < klass_stages[stage_key] unless cancelled?
      end

      define_method("past_#{stage_key}?") do
        klass_stages[stage] > klass_stages[stage_key] || cancelled?
      end

      define_method("cancelled_from_#{stage_key}?") do
        stage == 'cancelled' && stage_was == stage_key
      end
    end
  end
end
