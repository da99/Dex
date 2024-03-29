# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)
require "Dex/version"

Gem::Specification.new do |s|
  s.name        = "Dex"
  s.version     = Dex::VERSION
  s.authors     = ["da99"]
  s.email       = ["i-hate-spam-45671204@mailinator.com"]
  s.homepage    = "https://github.com/da99/Dex"
  s.summary     = %q{Log exceptions to sqlite3}
  s.description = %q{
    A simple function to log errors to sqlite3.
  }

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'bacon'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'Bacon_Colored'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'Exit_0'

  
  # Specify any dependencies here; for example:
  s.add_runtime_dependency 'sqlite3'
  s.add_runtime_dependency 'sequel'
  s.add_runtime_dependency 'terminal-table'
  s.add_runtime_dependency 'chronic_duration'
  s.add_runtime_dependency 'trollop'
  s.add_runtime_dependency 'term-ansicolor'
  s.add_runtime_dependency 'Backtrace_Array'
end
