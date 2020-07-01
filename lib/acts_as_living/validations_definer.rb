module ActsAsLiving::ValidationsDefiner
  def self.call(klass)
    klass.class_eval do
      include InstanceMethods

      validates :stage, presence: true

      validate :stage_progression, on: :update, if: :stage_changed?
      validate :initialized_stage, on: :create, if: :stage_changed?
    end
  end

  module InstanceMethods
    def stage_progression
      return if stage.to_s == self.class.dead_stage.to_s || stage == stage_after(stage_was)

      message = if stage_was == self.class.final_stage
                  "The contract can only be updated to '#{self.class.dead_stage}'"
                else
                  "The contract can only be updated to '#{self.class.dead_stage}' or '#{stage_after(stage_was)}'"
                end

      errors.add(:stage, message)
    end

    def initialized_stage
      return if stage == self.class.initial_stage

      errors.add(:stage, "Contract has to be initialized with '#{self.class.initial_stage}' stage")
    end
  end
end
