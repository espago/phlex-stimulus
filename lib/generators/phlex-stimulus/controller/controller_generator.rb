# typed: false
# frozen_string_literal: true

module Phlex::Stimulus::Generators
  class ControllerGenerator < ::Rails::Generators::NamedBase
    include GeneratorMixin

    source_root File.expand_path('templates', __dir__)

    def create_files
      template 'controller.ts.erb',
               File.join('app', 'javascript', 'controllers', class_path, "#{file_name}.ts")

      template 'component.rb.erb',
               File.join('app', 'components', class_path, "#{file_name}.rb")
      replace_with_template 'app/javascript/controllers/index.js'
    end
  end
end
