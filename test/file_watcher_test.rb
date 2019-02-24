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

  def test_watch_create
    # TODO
    true
  end

  def test_watch_alter
    # TODO
    true
  end

  def test_watch_delete
    # TODO
    true
  end
end
