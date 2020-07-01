# # frozen_string_literal: true

# module ActsAsLiving::CallbacksDefiner #:nodoc:
#   CALLBACK_TERMINATOR = if ::ActiveSupport::VERSION::MAJOR >= 5
#                           ->(_target, result) { result.call == false }
#                         else
#                           ->(_target, result) { result == false }
#                         end

#   # defines before, after and around callbaks for each period of the acts_as_living
#   #   e.g. before_cancelled { do_something }
#   #   e.g. after_activated :run_method
#   #   e.g. after_stage_change :run_method

#   def self.call(klass)
#     klass.class_eval do
#       include ActiveSupport::Callbacks
#       extend ClassMethods
#       include InstanceMethods

#       callbacks_for(:stage_change)
#       callbacks_for(:period_change)
#       stage_keys.each(&method(:stage_callbacks_for))
#       @periods.keys.each(&method(:lifeperiod_callbacks_for))
#     end
#   end

#   module InstanceMethods
#     def save(*args)
#       return super(*args) unless valid? && stage_changed? ||  valid? && new_record?

#       _run_stage_change_callbacks do
#         run_callbacks("stage_change_to_#{stage}") do
#           binding.pry if notice_of_termination_received?
#           period_changed? ? run_period_callbacks { binding.pry; 'hey'; super(*args) } : super(*args)
#         end
#       end
#     end

#     def save!(*args)
#       return super(*args) unless valid? && stage_changed? ||  valid? && new_record?

#       _run_stage_change_callbacks do
#         run_callbacks("stage_change_to_#{stage}") do
#           period_changed? ? run_period_callbacks { binding.pry; 'hey'; super(*args) } : super(*args)
#         end
#       end
#     end

#     protected

#     def run_period_callbacks(&block)
#       _run_period_change_callbacks do
#         _run_period_started_callbacks do
#           _run_period_ended_callbacks(&block)
#         end
#       end
#     end

#     def _run_period_started_callbacks(&block)
#       periods_started.inject(block) do |blk, period|
#         _run_period_started_callbacks(period, &blk)
#       end
#     end

#     def _run_period_ended_callbacks(&block)
#       periods_ended.inject(block) do |blk, period|
#         _run_period_ended_callbacks(period, &blk)
#       end
#     end

#     def _run_period_started_callbacks(period, &block)
#       run_callbacks("#{period}_started".to_sym, &block)
#     end

#     def _run_period_ended_callbacks(period, &block)
#       run_callbacks("#{period}_ended".to_sym, &block)
#     end
#   end

#   module ClassMethods
#     def lifeperiod_callbacks_for(period)
#       define_callback_methods_for("#{period}_started".to_sym)
#       define_callback_methods_for("#{period}_ended".to_sym)
#     end

#     def callbacks_for(callback_name)
#       define_callback_methods_for(callback_name)
#     end

#     def stage_callbacks_for(stage_name)
#       define_callback_methods_for("stage_change_to_#{stage_name}")
#     end

#     def _normalize_callback_options(options)
#       _normalize_callback_option(options, :only, :if)
#       _normalize_callback_option(options, :except, :unless)
#     end

#     def _normalize_callback_option(options, from, to)
#       return unless (from = options[from])

#       from_set = Array(from).map(&:to_s).to_set
#       from = proc { |c| from_set.include? c.notification_name.to_s }
#       options[to] = Array(options[to]).unshift(from)
#     end

#     # rubocop:disable Metrics/MethodLength
#     def define_callback_methods_for(callback_name)
#       define_callbacks(
#         callback_name,
#         terminator: CALLBACK_TERMINATOR,
#         skip_after_callbacks_if_terminated: true
#       )

#       define_singleton_method("before_#{callback_name}") do |method_or_block = nil, **options, &block|
#         method_or_block ||= block
#         _normalize_callback_options(options)
#         set_callback callback_name, :before, method_or_block, options
#       end

#       define_singleton_method("after_#{callback_name}") do |method_or_block = nil, **options, &block|
#         method_or_block ||= block
#         _normalize_callback_options(options)
#         set_callback callback_name, :after, method_or_block, options
#       end

#       define_singleton_method("around_#{callback_name}") do |method_or_block = nil, **options, &block|
#         method_or_block ||= block
#         _normalize_callback_options(options)
#         set_callback callback_name, :around, method_or_block, options
#       end
#     end
#     # rubocop:enable Metrics/MethodLength
#   end
# end
