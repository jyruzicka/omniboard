# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "omniboard"
  s.version = File.read("version.txt")
  s.license = "MIT"
  
  s.summary = "Gem summary here."
  s.description = "Gem description here."
  
  s.author = "Jan-Yves Ruzicka"
  s.email = "janyves.ruzicka@gmail.com"
  s.homepage = "https://github.com/jyruzicka/omniboard"
  
  s.files = File.read("Manifest").split("\n").select{ |l| !l.start_with?("#") && l != ""}
  s.require_paths << "lib"
  s.bindir = "bin"
  s.executables << "omniboard"
  s.extra_rdoc_files = ["README.md"]

  s.add_runtime_dependency "rubyfocus", "~> 0.5.0"
  s.add_runtime_dependency "~> 2.1"
end
