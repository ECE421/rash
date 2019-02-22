require 'simplecov'
SimpleCov.start do
  add_filter '/test/'
end

if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require 'tempfile'

def create_tempfile_test_file(name, content)
  tempfile = Tempfile.new(name)
  tfd = tempfile.open
  tfd.write(content)
  tfd.close
  assert_true(File.exist?(tempfile.path.to_s))
  tempfile
end

require 'test/unit'
require 'mocha/test_unit'

require 'cmd'
require 'basic_shell'
require 'file_watcher'
