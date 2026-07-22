# typed: true
# frozen_string_literal: true

require 'phlex/stimulus'

module Tapioca
  module Compilers
    class PhlexController < Tapioca::Dsl::Compiler
      ConstantType = type_member { { fixed: T.class_of(Phlex::Stimulus::Components::Controller) } }

      class << self
        # @override
        #: -> T::Enumerable[Module]
        def gather_constants
          all_classes.select { |c| c < Phlex::Stimulus::Components::Controller }
        end
      end

      MOD_NAME = 'PhlexControllerMethods' #: String

      # @override
      #: -> void
      def decorate
        root.create_path(constant) do |klass|
          klass.comments << RBI::Comment.new(
            <<~DOC
              A Phlex component that wraps the `#{constant.controller_name.inspect}` Stimulus controller.

              LINK: #{constant.controller_path}
            DOC
          )

          mod = klass.create_module(MOD_NAME)
          klass.create_extend(MOD_NAME)

          actions = constant.action_defs.sort_by(&:action_name)
          actions.each do |action|
            comments = [
              RBI::Comment.new(
                <<~DOC,
                  Returns the identifier of `#{action.action_name}`
                  action on `#{action.component.controller_name.inspect}` Stimulus controller

                  Result: `#{action.full_name.inspect}`
                DOC
              )
            ]
            mod.create_method(
              action.ruby_action_method_name,
              return_type: 'String',
              comments: comments,
            )
          end

          targets = constant.target_defs.sort_by(&:target_name)
          targets.each do |target|
            comments = [
              RBI::Comment.new(
                <<~DOC,
                  Returns the identifier of `#{target.target_name}`
                  target on `#{target.component.controller_name.inspect}` Stimulus controller

                  Result: `#{target.target_name.inspect}`
                DOC
              )
            ]
            mod.create_method(
              target.ruby_target_method_name,
              return_type: 'String',
              comments: comments,
            )
          end

        end

      end

    end
  end
end
