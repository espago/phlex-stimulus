# typed: true
# frozen_string_literal: true

module Phlex::On::Sorbet
  module Components
    # Abstract class for Phlex components
    # that wrap Stimulus.js controllers.
    #
    # @abstract
    class Controller < Base
      class ActionDefinition
        #: singleton(Controller)
        attr_reader :component
        #: String
        attr_reader :action_name

        #: (component: singleton(Controller), action_name: String) -> void
        def initialize(component:, action_name:)
          @component = component
          @action_name = action_name
        end

        #: -> String
        def full_name
          "#{@component.controller_name}##{@action_name}"
        end

        #: -> String
        def ruby_name
          @action_name.underscore
        end

        #: -> String
        def ruby_action_method_name
          "#{ruby_name}_action"
        end
      end

      class TargetDefinition
        #: singleton(Controller)
        attr_reader :component
        #: String
        attr_reader :target_name

        #: (component: singleton(Controller), target_name: String) -> void
        def initialize(component:, target_name:)
          @component = component
          @target_name = target_name
        end

        #: -> String
        def ruby_name
          @target_name.underscore
        end

        #: -> String
        def ruby_target_method_name
          "#{ruby_name}_target"
        end
      end

      class << self
        # Name of the Stimulus controller
        #
        #: String
        attr_accessor :controller_name

        #: -> String
        def controller_path
          name = controller_name
          sections = name.split('--')
          subpath = sections.map(&:underscore).join('/')

          "app/javascript/controllers/#{subpath}_controller.ts"
        end

        #: -> Array[ActionDefinition]
        def action_defs
          @action_defs ||= []
        end

        #: -> Array[TargetDefinition]
        def target_defs
          @target_defs ||= []
        end

        # Constructs a Stimulus dispatched event name
        # eg.
        #
        #     SummaryController.dispatched('ready') #=> "summary:ready"
        #
        #: (String) -> String
        def dispatched(event_name)
          "#{controller_name}:#{event_name}"
        end

        # Returns the name of the data attribute for the controller's targets without the initial `"data-"`
        # eg. `"summary-target"`
        #
        #: -> String
        def target_key
          "#{controller_name}-target"
        end

        # Returns the full name of the data attribute for the controller's targets
        # eg. `"data-summary-target"`
        #
        #: -> String
        def data_target_key
          "data-#{target_key}"
        end

        # Register actions that exist on the Stimulus controller.
        # Will define typed getter methods for each action.
        #
        #: (*Symbol) -> void
        def actions(*actions)
          actions.each do |action|
            action_def = ActionDefinition.new(
              component:   self,
              action_name: action.to_s,
            )
            action_defs << action_def

            instance_eval <<~RUBY, __FILE__, __LINE__ + 1
              def #{action_def.ruby_action_method_name}
                "\#{controller_name}##{action}"
              end
            RUBY
          end
        end

        # Register targets that exist on the Stimulus controller.
        # Will define typed getter methods for each target.
        #
        #: (*Symbol) -> void
        def targets(*targets)
          targets.each do |target|
            target_str = target.to_s
            target_def = TargetDefinition.new(
              component:   self,
              target_name: target_str,
            )
            target_defs << target_def

            instance_eval <<~RUBY, __FILE__, __LINE__ + 1
              def #{target_def.ruby_target_method_name}
                #{target_str.inspect}
              end
            RUBY
          end
        end

      end

      #: -> String
      def controller_name
        self.class.controller_name
      end

      # @overridable
      #: ?{ -> void } -> void
      def view_template(&block)
        div(data: { controller: self.class.controller_name }) do
          block&.call
        end
      end
    end
  end
end
