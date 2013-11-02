# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'semantic/ui/rails/version'

Gem::Specification.new do |spec|
  spec.name          = "semantic-ui-rails"
  spec.version       = Semantic::Ui::Rails::VERSION
  spec.authors       = ["nd0ut"]
  spec.email         = ["nd0ut.me@gmail.com"]
  spec.description   = %q{UI is the vocabulary of the web}
  spec.summary       = %q{Semantic empowers designers and developers by creating a language for sharing UI}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "less-rails"
  spec.add_dependency "autoprefixer-rails"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "binding_of_caller"
  spec.add_development_dependency "git"
end
