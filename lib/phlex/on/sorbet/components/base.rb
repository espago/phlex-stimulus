# typed: true
# frozen_string_literal: true

module Phlex::On::Sorbet
  module Components
    # Abstract class for Phlex components that render HTML with better sorbet and stimulus support.
    #
    # @abstract
    class Base < Phlex::HTML
      #: -> ApplicationController::HelperProxy
      def h = view_context

      #: -> String
      def inspect
        "#<#{self.class.name}>"
      end

      if defined?(Rails) && Rails.env.development?
        #: -> void
        def before_template
          newline
          comment { "Before #{self.class.name}" }
          newline
          super
        end

        #: -> void
        def after_template
          newline
          comment { "After #{self.class.name}" }
          newline
          super
        end
      end

      # Constructs a Stimulus event hook string
      # eg.
      #
      #     event('click', 'summary#redirect') #=> "click->summary#redirect"
      #
      #: (String, String) -> String
      def event(event_name, full_action_name)
        "#{event_name}->#{full_action_name}"
      end

      # Converts a Ruby boolean to a boolean
      # value in HTML attributes.
      #
      # Returns `"true"` for a truthy value, otherwise `nil`.
      #
      #: (bool) -> String?
      def attrbool(val)
        'true' if val
      end

      # Output a single newline character.
      # If a block is given, a space will be output before and after the block.
      #
      #: ?{ -> void } -> void
      def newline(&block)
        plain "\n"
        return unless block

        block.call
        plain "\n"
      end

      # Merges the given list of class names (with optional nils)
      # into a single class string separated by spaces.
      #
      #: (*String?) -> String
      def class_list(*args)
        buff = String.new

        args.each do |arg|
          next unless arg

          buff << arg << ' '
        end

        buff.strip
      end

      #: (Array[String?]) -> String
      def class_list!(args)
        class_list(*T.unsafe(args))
      end

      alias strlist class_list
      alias strlist! class_list!

      #: (String) -> bool
      def image_exists?(path)
        Boolean(h.resolve_asset_path(path))
      end

    end
  end
end
