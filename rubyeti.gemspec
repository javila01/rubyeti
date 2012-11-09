Gem::Specification.new do |s|
  s.name        = 'rubyeti'
  s.version     = '0.0.2'
  s.date        = '2010-11-08'
  s.summary     = "A Ruby interface to ETI"
  s.description = "Dependency test"
  s.authors     = ["Christopher Lenart"]
  s.email       = 'clenart1@gmail.com'
  s.files       = Dir.glob("lib/**/*") + Dir.glob("test/**/*") +["README.md"]
  s.add_runtime_dependency 'nokogiri'
  s.add_runtime_dependency 'typhoeus'
  s.homepage    =
    'http://github.com/clenart/rubyeti'
end
