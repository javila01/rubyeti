Gem::Specification.new do |s|
  s.name        = 'rubyeti'
  s.version     = '0.0.9'
  s.date        = '2010-11-12'
  s.summary     = "A Ruby interface to ETI"
  s.description = "Pre-release test"
  s.authors     = ["Christopher Lenart"]
  s.email       = 'clenart1@gmail.com'
  s.files       = Dir.glob("lib/**/*") + Dir.glob("test/**/*") +["README.md"]
  s.add_runtime_dependency 'nokogiri'
  s.add_runtime_dependency 'typhoeus'
  s.homepage    =
    'https://github.com/clenart/rubyeti'
end
