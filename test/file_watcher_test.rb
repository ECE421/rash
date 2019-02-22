require_relative 'helper'

class FileWatcherTest < Test::Unit::TestCase
  def setup
    @shell = FileWatcher.new
  end

  def teardown
    # Do nothing
  end

  def test_initialization
    assert_true(@shell.is_a?(FileWatcher))
    assert_true(@shell.is_a?(Cmd))
  end
end
