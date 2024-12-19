require_relative 'lib/jekyll-sketchviz/version'

Gem::Specification.new do |spec|
  host = 'https://github.com/cprima/jekyll-sketchviz'

  spec.authors               = ['Christian Prior-Mamulyan']
  spec.description           = <<~END_DESC
    Write a longer description of the gem.
    Use as many lines as you like.
  END_DESC
  spec.email                 = ['cprior@gmail.com']
  spec.files                 = Dir['.rubocop.yml', 'LICENSE.*', 'Rakefile', '{lib,spec}/**/*', '*.gemspec', '*.md']
  spec.homepage              = 'https://github.com/cprima/jekyll-sketchviz'
  spec.license               = 'MIT'
  spec.metadata = {
    'allowed_push_host' => 'https://rubygems.org',
    'bug_tracker_uri'   => "#{host}/issues",
    'changelog_uri'     => "#{host}/CHANGELOG.md",
    'homepage_uri'      => spec.homepage,
    'source_code_uri'   => host,
  }
  spec.name                 = 'jekyll-sketchviz'
  spec.post_install_message = <<~END_MESSAGE

    Thanks for installing #{spec.name}!

  END_MESSAGE
  spec.require_paths         = ['lib']
  spec.required_ruby_version = '>= 3.1.0'
  spec.summary               = 'Write summary of what the gem is for'
  spec.version               = JekyllSketchviz::VERSION
  spec.add_dependency 'jekyll', '>= 3.5.0'
  spec.add_dependency 'jekyll_plugin_support', '>= 0.7.0'
end
