# typed: false
# frozen_string_literal: true

module Phlex::Stimulus::Generators
  class ControllerGenerator < ::Rails::Generators::NamedBase
    include GeneratorMixin

    source_root File.expand_path('templates', __dir__)

    def create_files
      template 'controller.ts.erb',
               File.join(destination_root, 'app', 'javascript', 'controllers', class_path, "#{file_name}_controller.ts")

      template 'component.rb.erb',
               File.join(destination_root, 'app', 'components', class_path, "#{file_name}.rb")

      append_to_file File.join(destination_root, 'app', 'javascript', 'controllers', 'index.ts'),
                     "import \"./#{class_path}/#{file_name}_controller\""
    end
  end
end
