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

  def test_smoke_watch_create
    test_file = create_tempfile_test_file('test_file', 'test content')

    Readline.stubs(:readline)
            .returns('watch create exit 1 ' + test_file.path.to_s, 'exit')
    @shell.cmd_loop
  end

  def test_smoke_watch_alter
    test_file = create_tempfile_test_file('test_file', 'test content')

    Readline.stubs(:readline)
            .returns('watch alter print 1 ' + test_file.path.to_s, 'exit')
    @shell.cmd_loop
  end

  def test_smoke_watch_delete
    test_file = create_tempfile_test_file('test_file', 'test content')

    Readline.stubs(:readline)
            .returns('watch delete print 1 ' + test_file.path.to_s, 'exit')
    @shell.cmd_loop
  end
end
