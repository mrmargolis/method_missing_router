# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "method_missing_router/version"

Gem::Specification.new do |s|
  s.name        = "method_missing_router"
  s.version     = MethodMissingRouter::VERSION
  s.authors     = ["Matt Margolis"]
  s.email       = ["matt@mattmargolis.net"]
  s.homepage    = ""
  s.summary     = %q{Declarative method routing for method_missing}
  s.description = %q{Use regular expressions to route missing methods}

  s.rubyforge_project = "method_missing_router"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
