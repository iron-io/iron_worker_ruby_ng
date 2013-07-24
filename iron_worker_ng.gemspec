require File.expand_path('../lib/iron_worker_ng/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Andrew Kirilenko', 'Iron.io, Inc']
  gem.email         = ['info@iron.io']
  gem.description   = 'New generation ruby client for IronWorker'
  gem.summary       = 'New generation ruby client for IronWorker'
  gem.homepage      = 'https://github.com/iron-io/iron_worker_ruby_ng'

  gem.files         = Dir.glob('lib/**/**') + ['README.md', 'LICENSE']
  gem.executables   = 'iron_worker'
  gem.name          = 'iron_worker_ng'
  gem.require_paths = ['lib']
  gem.version       = IronWorkerNG::VERSION

  gem.required_rubygems_version = '>= 1.3.6'
  gem.required_ruby_version = Gem::Requirement.new('>= 1.8')

  gem.add_runtime_dependency 'iron_core', '>= 1.0.0'
  gem.add_runtime_dependency 'bundler', '>= 1.2.0'
  gem.add_runtime_dependency 'rubyzip', '>= 0.9.9'

  gem.add_development_dependency 'test-unit'
  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'minitest-reporters', '>= 0.5.0'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'twitter'
  gem.add_development_dependency 'actionmailer'
  gem.add_development_dependency 'iron_cache', '>= 1.4.0'
  gem.add_development_dependency 'go'
end
