# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "omniboard"
  s.version = File.read("version.txt")
  s.license = "MIT"
  
  s.summary = "Display Omnifocus libraries as kanban boards, with ruby."
  s.description = "A pure-ruby library (and binary) to read and parse Omnifocus task lists as kanban boards."
  
  s.author = "Jan-Yves Ruzicka"
  s.email = "jan@1klb.com"
  s.homepage = "https://github.com/jyruzicka/omniboard"
  
  s.files = File.read("Manifest").split("\n").select{ |l| !l.start_with?("#") && l != ""}
  s.require_paths << "lib"
  s.bindir = "bin"
  s.executables << "omniboard"
  s.extra_rdoc_files = ["README.md"]

  s.add_runtime_dependency "rubyfocus", "~> 0.5", ">= 0.5.13"
  s.add_runtime_dependency "optimist", "~> 3.0"
end
