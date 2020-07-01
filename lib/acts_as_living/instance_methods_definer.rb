# frozen_string_literal: true

module ActsAsLiving::InstanceMethodsDefiner
  def self.call(klass)
    klass.class_eval do
      extend ClassMethods
      include InstanceMethods

      @life_stages.each(&method(:define_stage_queries))

      @status_keys.each(&method(:define_changed_queries))
    end
  end

  module InstanceMethods
    def status_after(status)
      self.class.status_after(status)
    end

    def statuses
      self.class.statuses
    end

    def status_before(status)
      self.class.status_before(status)
    end

    def to_next_status
      update(status: next_status)
    end

    def to_next_status!
      update!(status: next_status)
    end

    def next_status
      status_after(status) if status
    end

    def to_previous_status
      update(status: previous_status)
    end

    def to_previous_status!
      update!(status: previous_status)
    end

    def previous_status
      status_before(status)
    end

    def final_status?
      self.class.final_status?(status)
    end

    def initial_status?
      self.class.initial_status?(status)
    end

    def dead_status?
      self.class.dead_status == status
    end

    def dead_or_finalized?
      dead_status? || final_status?
    end

    def klass_stages_with_ranges
      self.class.stages_with_ranges
    end

    def klass_life_stages_for(status)
      self.class.life_stages_for(status)
    end

    def klass_statuses
      self.class.statuses
    end

    def locked?(&block)
      return unless block

      @locked_on.to_set.intersect? [status, status_was].to_set
    end

    def life_stages
      klass_life_stages_for(status)
    end

    def life_stage_changed?
      klass_life_stages_for(status) != klass_life_stages_for(status_was)
    end

    def life_stages_started
      klass_life_stages_for(status) - klass_life_stages_for(status_was)
    end

    def life_stages_ended
      klass_life_stages_for(status_was) - klass_life_stages_for(status)
    end
  end

  module ClassMethods
    def define_stage_queries(stage, delimiters)
      define_method("#{stage}?") do
        if delimiters.length == 1
          klass_statuses[status] == klass_statuses[delimiters]
        else
          klass_statuses[status] >= klass_statuses[delimiters.first] &&
            klass_statuses[status] <= klass_statuses[delimiters.second]
        end
      end

      define_method("pre_#{stage}?") do
        klass_statuses[status] < klass_statuses[delimiters.first] unless cancelled?
      end

      define_method("past_#{stage}?") do
        klass_statuses[status] > klass_statuses[delimiters.last] || cancelled?
      end
    end

    def define_changed_queries(status_key)
      define_method("status_changed_to_#{status_key}?") do
        status_changed? && status_was == status_key
      end

      define_method("pre_#{status_key}?") do
        klass_statuses[status] < klass_statuses[status_key] unless cancelled?
      end

      define_method("past_#{status_key}?") do
        klass_statuses[status] > klass_statuses[status_key] || cancelled?
      end

      define_method("cancelled_from_#{status_key}?") do
        status == 'cancelled' && status_was == status_key
      end
    end
  end
end
