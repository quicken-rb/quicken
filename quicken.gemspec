# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'quicken/version'

Gem::Specification.new do |spec|
  spec.name          = 'quicken'
  spec.version       = Quicken::VERSION
  spec.authors       = ['Matteo Joliveau']
  spec.email         = ['matteojoliveau@gmail.com']

  spec.summary       = 'Stimulate your development! Quicken is a command line tool to generate software projects based on clear, repeatable recipes'
  spec.description   = 'Quicken is a software project scaffolder written in Ruby. It allows to create projects based on a "recipe" that defines the language, needed tools (build tools like Maven, Gradle or SCons, VCSs like Git or Mercurial), license and other parameters. It uses templates to setup files.

'
  spec.homepage      = 'https://github.com/quicken-rb/quicken'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-collection_matchers', '~> 1.1'
  spec.add_development_dependency 'rubocop', '~> 0.58.2'
  spec.add_development_dependency 'pry', '~> 0.11.3'
  spec.add_runtime_dependency 'thor', '~> 0.20.0'
  spec.add_runtime_dependency 'simple_command', '~> 0.0.9'
  spec.add_runtime_dependency 'activesupport', '~> 5.2'
end
