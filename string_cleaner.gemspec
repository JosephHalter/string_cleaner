# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{string_cleaner}
  s.version = "1.0.0"
  s.authors = ["Joseph Halter"]
  s.date = %q{2010-10-18}
  s.email = %q{joseph@openhood.com}
  s.required_ruby_version = ">= 2.6"
  s.license = "MIT"
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "lib/string_cleaner.rb",
     "spec/spec_helper.rb",
     "spec/string_cleaner_spec.rb",
     "string_cleaner.gemspec"
  ]
  s.homepage = %q{http://github.com/JosephHalter/string_cleaner}
  s.require_paths = ["lib"]
  s.summary = %q{Fix invalid UTF-8 and wipe invisible chars, compatible with Ruby 2.6+ with extensive specs}
  s.test_files = [
    "spec/spec_helper.rb",
     "spec/string_cleaner_spec.rb"
  ]
  s.add_runtime_dependency "talentbox-unidecoder", "2.0.0"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
end
