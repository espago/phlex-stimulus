# typed: false
# frozen_string_literal: true

module Phlex::Stimulus::Generators
  class InstallGenerator < ::Rails::Generators::Base
    include GeneratorMixin

    source_root File.expand_path('templates', __dir__)

    def remove_importmap_if_present
      return unless importmap_installed?

      say 'Importmap detected — removing it', :yellow
      remove_importmap
    end

    def install_jsbundling_unless_present
      return if jsbundling_installed?

      say 'Installing jsbundling-rails (esbuild)', :yellow
      install_jsbundling_with_esbuild
    end

    def create_files
      copy_template 'app/components.rb'
      copy_template 'app/components/base.rb'
      copy_template 'app/components/controller.rb'
      copy_template 'app/components/chain_controller.rb'
      copy_template 'app/components/controller_template.rb'
      copy_template 'app/components/controller_chain.rb'
      copy_template 'app/components/classlist_controller.rb'
      copy_template 'app/components/log_controller.rb'
      copy_template 'app/components/sleep_controller.rb'

      remove_file File.join(destination_root, 'app/javascript/application.js')
      copy_template 'app/javascript/application.ts'

      remove_file File.join(destination_root, 'app/javascript/controllers/application.js')
      copy_template 'app/javascript/controllers/application.ts'

      remove_file File.join(destination_root, 'app/javascript/controllers/index.js')
      copy_template 'app/javascript/controllers/index.ts'

      copy_template 'app/javascript/controllers/typed_controller.ts'
      copy_template 'app/javascript/controllers/chain_controller.ts'
      copy_template 'app/javascript/controllers/chainable_controller.ts'
      copy_template 'app/javascript/controllers/log_controller.ts'
      copy_template 'app/javascript/controllers/sleep_controller.ts'
      copy_template 'app/javascript/controllers/classlist_controller.ts'

      copy_template 'app/javascript/utils/misc.ts'
      copy_template 'app/javascript/utils/template.ts'
    end

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

    def importmap_installed?
      File.exist?(File.join(destination_root, 'config/importmap.rb')) ||
        gemfile_includes?('importmap-rails')
    end

    def jsbundling_installed?
      gemfile_includes?('jsbundling-rails')
    end

    def remove_importmap
      remove_file File.join(destination_root, 'config/importmap.rb')
      gsub_file 'Gemfile', /^\s*gem ["']importmap-rails["'].*\n/, ''

      layout = File.join('app/views/layouts', 'application.html.erb')
      return unless File.exist?(File.join(destination_root, layout))

      gsub_file layout, /^\s*<%=\s*javascript_importmap_tags.*%>\n/, ''
    end

    def install_jsbundling_with_esbuild
      gem 'jsbundling-rails'
      Bundler.with_original_env { run 'bundle install' }
      rails_command 'javascript:install:esbuild'
    end

    def gemfile_includes?(gem_name)
      gemfile = File.join(destination_root, 'Gemfile')
      return false unless File.exist?(gemfile)

      File.read(gemfile).match?(/^\s*gem ["']#{Regexp.escape(gem_name)}["']/)
    end
  end
end
