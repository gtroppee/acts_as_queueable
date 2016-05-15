# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'acts_as_queueable/version'

Gem::Specification.new do |gem|
  gem.name          = 'acts_as_queueable'
  gem.version       = ActsAsQueueable::VERSION
  gem.authors       = ['Guillaume Troppee']
  gem.email         = %w(gtroppee@gmail.com)
  gem.description   = %q{With ActsAsQueueable, you can add a simple persisted queue structure.}
  gem.summary       = 'Persisted queueing for Rails.'
  gem.homepage      = 'https://github.com/gtroppee/acts_as_queueable'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^spec/})
  gem.require_paths = ['lib']
  gem.required_ruby_version     = '>= 1.9.3'

  if File.exist?('UPGRADING.md')
    gem.post_install_message = File.read('UPGRADING.md')
  end

  gem.add_runtime_dependency 'activerecord', ['>= 3.2', '< 5']
end
