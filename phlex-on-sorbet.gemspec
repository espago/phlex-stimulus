# frozen_string_literal: true

require_relative 'lib/phlex/on/sorbet/version'

Gem::Specification.new do |spec|
  spec.name = 'phlex-on-sorbet'
  spec.version = Phlex::On::Sorbet::VERSION
  spec.authors = ['Espago', 'Mateusz Drewniak']
  spec.email = ['m.drewniak@espago.com']

  spec.summary = 'Extended support for sorbet in phlex'
  spec.description = spec.summary
  spec.homepage = 'https://github.com/espago/phlex-on-sorbet'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.3.0'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = 'https://github.com/espago/phlex-on-sorbet/blob/main/CHANGELOG.md'
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore test/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'booleans', '~> 0.1'
  spec.add_dependency 'phlex', '~> 2.0'
  spec.add_dependency 'phlex-rails', '~> 2.0'
  spec.add_dependency 'rails', '~> 8.1'
end
