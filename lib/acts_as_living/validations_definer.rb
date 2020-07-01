module ActsAsLiving::ValidationsDefiner
  def self.call(klass)
    klass.class_eval do
      include InstanceMethods

      validates :status, presence: true

      validate :status_progression, on: :update, if: :status_changed?
      validate :initialized_status, on: :create, if: :status_changed?
    end
  end

  module InstanceMethods
    def status_progression
      return if status.to_s == self.class.dead_status.to_s || status == status_after(status_was)

      message = if status_was == self.class.final_status
                  "The contract can only be updated to '#{self.class.dead_status}'"
                else
                  "The contract can only be updated to '#{self.class.dead_status}' or '#{status_after(status_was)}'"
                end

      errors.add(:status, message)
    end

    def initialized_status
      return if status == self.class.initial_status

      errors.add(:status, "Contract has to be initialized with '#{self.class.initial_status}' status")
    end
  end
end
