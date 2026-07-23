# typed: false
# frozen_string_literal: true

require_relative '../generator_mixin'

module Phlex::Stimulus::Generators
  class ControllerGenerator < ::Rails::Generators::NamedBase
    include GeneratorMixin

    source_root File.expand_path('templates', __dir__)

    #: -> void
    def create_files
      template 'controller.ts.erb',
               File.join(destination_root, 'app', 'javascript', 'controllers', class_path, "#{file_name}_controller.ts")

      template 'component.rb.erb',
               File.join(destination_root, 'app', 'components', class_path, "#{file_name}_controller.rb")

      append_to_file File.join(destination_root, 'app', 'javascript', 'controllers', 'index.ts'),
                     "import \"./#{class_path}/#{file_name}_controller\"\n"
    end

    private

    #: -> String
    def path_to_root_controller_dir
      @path_to_root_controller_dir ||= begin
        result = String.new
        result << './'
        class_path.length.times do
          result << '../'
        end

        result
      end
    end

    #: -> String
    def stimulus_controller_name
      @stimulus_controller_name ||= (class_path + [file_name]).join('--')
    end

    #: -> String
    def class_name_without_namespace
      file_name.camelize
    end
  end
end
