lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "merci/version"

Gem::Specification.new do |spec|
  spec.name          = "merci"
  spec.version       = Merci::VERSION
  spec.authors       = ["Rails"]
  spec.email         = ["rails@shopify.com"]

  spec.summary       = "Give thanks (in the form of github stars) to your fellow Rubyist"
  spec.description   = "Automatically star ruby gem your project depend on"
  spec.homepage      = "https://github.com/shopify/merci"
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/shopify/merci"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
