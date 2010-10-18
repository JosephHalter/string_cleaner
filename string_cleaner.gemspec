# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{string_cleaner}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Joseph Halter"]
  s.date = %q{2009-08-26}
  s.email = %q{joseph@openhood.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/string_cleaner.rb",
     "spec/spec_helper.rb",
     "spec/string_cleaner_spec.rb",
     "string_cleaner.gemspec"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/JosephHalter/string_cleaner}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Fix invalid UTF-8 and wipe invisible chars, fully compatible with Ruby 1.8 & 1.9 with extensive specs}
  s.test_files = [
    "spec/spec_helper.rb",
     "spec/string_cleaner_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
