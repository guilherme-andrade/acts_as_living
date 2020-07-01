# # frozen_string_literal: true

# module ActsAsLiving::CallbacksDefiner #:nodoc:
#   CALLBACK_TERMINATOR = if ::ActiveSupport::VERSION::MAJOR >= 5
#                           ->(_target, result) { result.call == false }
#                         else
#                           ->(_target, result) { result == false }
#                         end

#   # defines before, after and around callbaks for each stage of the acts_as_living
#   #   e.g. before_cancelled { do_something }
#   #   e.g. after_activated :run_method
#   #   e.g. after_status_change :run_method

#   def self.call(klass)
#     klass.class_eval do
#       include ActiveSupport::Callbacks
#       extend ClassMethods
#       include InstanceMethods

#       callbacks_for(:status_change)
#       callbacks_for(:life_stage_change)
#       status_keys.each(&method(:status_callbacks_for))
#       @life_stages.keys.each(&method(:lifestage_callbacks_for))
#     end
#   end

#   module InstanceMethods
#     def save(*args)
#       return super(*args) unless valid? && status_changed? ||  valid? && new_record?

#       _run_status_change_callbacks do
#         run_callbacks("status_change_to_#{status}") do
#           binding.pry if notice_of_termination_received?
#           life_stage_changed? ? run_life_stage_callbacks { binding.pry; 'hey'; super(*args) } : super(*args)
#         end
#       end
#     end

#     def save!(*args)
#       return super(*args) unless valid? && status_changed? ||  valid? && new_record?

#       _run_status_change_callbacks do
#         run_callbacks("status_change_to_#{status}") do
#           life_stage_changed? ? run_life_stage_callbacks { binding.pry; 'hey'; super(*args) } : super(*args)
#         end
#       end
#     end

#     protected

#     def run_life_stage_callbacks(&block)
#       _run_life_stage_change_callbacks do
#         _run_life_stage_started_callbacks do
#           _run_life_stage_ended_callbacks(&block)
#         end
#       end
#     end

#     def _run_life_stage_started_callbacks(&block)
#       life_stages_started.inject(block) do |blk, stage|
#         _run_stage_started_callbacks(stage, &blk)
#       end
#     end

#     def _run_life_stage_ended_callbacks(&block)
#       life_stages_ended.inject(block) do |blk, stage|
#         _run_stage_ended_callbacks(stage, &blk)
#       end
#     end

#     def _run_stage_started_callbacks(stage, &block)
#       run_callbacks("#{stage}_started".to_sym, &block)
#     end

#     def _run_stage_ended_callbacks(stage, &block)
#       run_callbacks("#{stage}_ended".to_sym, &block)
#     end
#   end

#   module ClassMethods
#     def lifestage_callbacks_for(stage)
#       define_callback_methods_for("#{stage}_started".to_sym)
#       define_callback_methods_for("#{stage}_ended".to_sym)
#     end

#     def callbacks_for(callback_name)
#       define_callback_methods_for(callback_name)
#     end

#     def status_callbacks_for(status_name)
#       define_callback_methods_for("status_change_to_#{status_name}")
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
