lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "prcs/version"

Gem::Specification.new do |spec|
  spec.name          = "prcs"
  spec.version       = PRCS::VERSION
  spec.authors       = ["Kasper Grubbe"]
  spec.email         = ["prcs@kaspergrubbe.com"]

  spec.summary       = %q{A wrapper around ChildProcess}
  spec.homepage      = "https://github.com/kaspergrubbe/PRCS"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/kaspergrubbe/PRCS"
  spec.metadata["changelog_uri"] = "https://github.com/kaspergrubbe/PRCS/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "childprocess", "~> 3.0", ">= 3.0.0"
    spec.add_dependency "ffi", '~> 1.12'

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry", "~> 0.12"
end
