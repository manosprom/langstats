
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'langstats/version'

Gem::Specification.new do |spec|
  spec.name          = 'langstats'
  spec.version       = Langstats::VERSION
  spec.authors       = ['Emmanouil Proimakis']
  spec.email         = ['e.proimakis@gmail.com']

  spec.summary       = 'langstats consone application'
  spec.description   = 'An application that create a json object including the programming language used on the repositories of an organization on github'
  spec.homepage      = "http://mysite.com"
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'webmock', '~> 3.3'
  spec.add_development_dependency 'simplecov', '~> 0.15.1'
  spec.add_dependency 'faraday', '~> 0.9.2'
  spec.add_dependency 'json', '~> 1.8', '>= 1.8.3'
  spec.add_dependency 'octokit', '~> 4.3'
  spec.add_dependency 'OptionParser', '~> 0.5.1'
  spec.add_dependency 'rest-client', '~> 1.8'
end
