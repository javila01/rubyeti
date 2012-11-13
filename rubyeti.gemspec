Gem::Specification.new do |s|
  s.name        = 'rubyeti'
  s.version     = '0.1.0'
  s.date        = '2010-11-12'
  s.summary     = "A Ruby interface to ETI"
  s.description = "Version 0.1.0"
  s.authors     = ["Christopher Lenart"]
  s.email       = 'clenart1@gmail.com'
  s.files       = Dir.glob("lib/**/*") + Dir.glob("test/**/*") +["README.md"]
  s.add_dependency 'nokogiri', ["1.5.5"]
  s.add_dependency 'typhoeus', ["0.5.0"]
  s.homepage    =
    'https://github.com/clenart/rubyeti'
end
