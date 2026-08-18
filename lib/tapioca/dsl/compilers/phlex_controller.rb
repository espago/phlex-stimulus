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
            <<~DOC,
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
              ),
            ]
            mod.create_method(
              action.ruby_action_method_name,
              return_type: 'String',
              comments:    comments,
            )

            comments = [
              RBI::Comment.new(
                <<~DOC,
                  Returns na anchor hash that can be used to attach `#{action.action_name}`
                  action on `#{action.component.controller_name.inspect}` Stimulus controller
                  to a particular DOM event.
                DOC
              ),
            ]
            mod.create_method(
              action.ruby_on_method_name,
              comments:    comments,
            ) do |method|
              method.add_param('event_name')
              action.params.each do |param|
                if param.optional
                  method.add_kw_opt_param(param.param_name, 'nil')
                else
                  method.add_kw_param(param.param_name)
                end
              end

              method.add_sig do |sig|
                sig.return_type = 'T::Hash[T.any(Symbol, String), String]'

                sig.add_param('event_name', 'String')
                action.params.each do |param|
                  if param.optional
                    sig.add_param(param.param_name, 'T.nilable(String)')
                  else
                    sig.add_param(param.param_name, 'String')
                  end
                end
              end
            end
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
              ),
            ]
            mod.create_method(
              target.ruby_target_method_name,
              return_type: 'String',
              comments:    comments,
            )

            comments = [
              RBI::Comment.new(
                <<~DOC,
                  Returns an anchor hash for `#{target.target_name}`
                  target on `#{target.component.controller_name.inspect}` Stimulus controller
                  that can be used to attach this target to a particular DOM element.

                  Result: `{ #{constant.target_key} => #{target.target_name.inspect} }`
                DOC
              ),
            ]
            mod.create_method(
              target.ruby_target_anchor_method_name,
              return_type: 'T::Hash[String, String]',
              comments:    comments,
            )
          end

        end

      end

    end
  end
end
