# frozen_string_literal: true

require_relative 'lib/jekyll_sketchviz/version'

Gem::Specification.new do |spec|
  host = 'https://github.com/cprima/jekyll-sketchviz'

  spec.authors               = ['Christian Prior-Mamulyan']
  spec.description           = <<~END_DESC
    jekyll-sketchviz is a Jekyll plugin that integrates Graphviz and Rough.js to process .dot files into SVG diagrams during the site build. It supports configurable output formats, including unstyled filesystem SVGs and inline SVGs styled via CSS. The plugin leverages Jekyll collections for input management and provides a Liquid tag API for flexible inclusion in site content.
  END_DESC
  spec.email                 = ['cprior@gmail.com']
  spec.files                 = Dir['.rubocop.yml', 'LICENSE.*', 'Rakefile', '{lib,spec}/**/*', '*.gemspec', '*.md']
  spec.homepage              = 'https://cprima.github.io/jekyll-sketchviz'
  spec.license               = 'CC-BY-4.0'
  spec.metadata = {
    'allowed_push_host' => 'https://rubygems.org',
    'bug_tracker_uri' => "#{host}/issues",
    'changelog_uri' => "#{host}/CHANGELOG.md",
    'homepage_uri' => spec.homepage,
    'source_code_uri' => host,
    'rubygems_mfa_required' => 'true'
  }
  spec.name                 = 'jekyll-sketchviz'
  spec.post_install_message = <<~END_MESSAGE

    Thanks for installing #{spec.name}!

  END_MESSAGE
  spec.require_paths         = ['lib']
  spec.required_ruby_version = '>= 3.3.0'
  spec.summary               = 'A Jekyll plugin to transform Graphviz .dot files into sketch-style SVGs using Rough.js.'
  spec.version               = JekyllSketchviz::VERSION
  spec.add_dependency 'jekyll', '~> 4.0'
end
