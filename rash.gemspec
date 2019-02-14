require 'rake'

Gem::Specification.new do |s|
  s.name = 'rash'
  s.version = '0.0.0'
  s.licenses = ['MIT']
  s.summary = 'A custom shell made in Ruby'
  s.description = "A custom shell made in Ruby implementing
some custom features such as: a process time manager and a file watcher"
  s.authors = ['Nathan Klapstein', 'Thomas Lorincz']
  s.email = 'nklapste@ualberta.ca'
  s.homepage = 'https://github.com/ECE421/rash'

  s.files = FileList['lib/*.rb'].to_a
  s.test_files = FileList['test/*.rb'].to_a
  s.require_paths = ['lib']
end
