lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nexaas/auditor/version'

Gem::Specification.new do |spec|
  spec.name          = "nexaas-auditor"
  spec.version       = Nexaas::Auditor::VERSION
  spec.authors       = ["Rodrigo Tassinari de Oliveira"]
  spec.email         = ["rodrigo@pittlandia.net"]

  spec.summary       = 'Common code for audit logs and statistcs tracking for Nexaas Rails apps, '\
                       'via ActiveSupport::Instrumentation.'
  spec.description   = 'Common code for audit logs and statistcs tracking for Nexaas Rails apps, '\
                       'via ActiveSupport::Instrumentation.'
  spec.homepage      = "https://github.com/myfreecomm/nexaas-auditor"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "nunes", ">= 0.4"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "guard-rspec", "~> 4.7"
  spec.add_development_dependency "rake", "~> 11.1"
  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_development_dependency "test_notifier", "~> 2.0"
end
