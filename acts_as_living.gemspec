
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'acts_as_living/version'

Gem::Specification.new do |spec|
  spec.name          = 'acts_as_living'
  spec.version       = ActsAsLiving::VERSION
  spec.authors       = ['Guilherme Andrade']
  spec.email         = ['guilherme.andrade.ao@gmail.com']

  spec.summary       = 'An ActiveRecord plugin that assists in acts_as_living stage progressions.'
  spec.description   = 'An ActiveRecord plugin that assists in acts_as_living stage progressions.'
  spec.homepage      = 'https://github.com/guilherme-andrade/acts_as_living'
  spec.license       = 'MIT'

  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/guilherme-andrade/acts_as_living'
    spec.metadata['changelog_uri'] = 'https://github.com/guilherme-andrade/acts_as_living/blob/master/Changelog.md'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files = Dir['lib/**/*', 'Changelog.md', 'README.md']
  spec.bindir        = 'exe'
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '~> 6.0', '>= 6.0.3'
  spec.add_dependency 'activesupport', '>= 6.0.3', '< 8'
  spec.add_dependency 'railties', '~> 6.0', '>= 6.0.3'

  spec.required_ruby_version = '>=2.5.0'
end
