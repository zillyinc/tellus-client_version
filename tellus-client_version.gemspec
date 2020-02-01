
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tellus/client_version/version'

Gem::Specification.new do |spec|
  spec.name          = 'tellus-client_version'
  spec.version       = Tellus::ClientVersion::VERSION
  spec.authors       = ['Calvin Tuong']
  spec.email         = ['calvin@tellusapp.com']

  spec.summary       = 'Utility to parse Tellus API client version headers.'
  spec.homepage      = 'https://github.com/zillyinc/tellus-client_version'

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = ''

    spec.metadata['homepage_uri'] = spec.homepage
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '~> 6.0'
  spec.add_dependency 'request_store', '~> 1.5'

  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.9'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-stack_explorer'
end
