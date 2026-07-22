# typed: false
# frozen_string_literal: true

module Phlex::Stimulus::Generators
  module GeneratorMixin
    private

    #: (String) -> void
    def replace_with_template(path)
      app_path = File.join(destination_root, path)
      remove_file app_path
      template "#{path}.erb", app_path
    end

    #: (String) -> void
    def copy_template(path)
      template "#{path}.erb",
               File.join(destination_root, path)
    end
  end
end
