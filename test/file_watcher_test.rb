require_relative 'helper'

class FileWatcherTest < Test::Unit::TestCase
  def setup
    @shell = FileWatcher.new
    @stdout = StringIO.new
    $stdout = @stdout
  end

  def teardown
    # Do nothing
  end

  def test_initialization
    assert_true(@shell.is_a?(FileWatcher))
    assert_true(@shell.is_a?(Cmd))
  end

  def test_help
    @shell.help_watch(nil)
    assert_equal(
      "Usage: watch [BEHAVIOUR] [ACTION] [DURATION] [*FILENAMES]\n"\
      "Description: Watch files denoted by FILENAMES for BEHAVIOUR.\n"\
      "BEHAVIOUR:\n"\
      "\tCreate: #{@shell.valid_c_behaviours}\n"\
      "\tAlter/Modify: #{@shell.valid_a_behaviours}\n"\
      "\tDelete: #{@shell.valid_d_behaviours}\n"\
      "ACTION:\n"\
      "\t#{@shell.valid_actions}\n"\
      "DURATION:\n"\
      "\tAny non-negative integer.\n"\
      "*FILENAMES:\n"\
      "\tA space-separated list of files to watch.\n",
      @stdout.string
    )
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

  def test_invalid_behaviour
    @shell.do_watch('invalid print 5 hello.rb hello.cpp')
    assert_equal(
      "Invalid behaviour: invalid. Please use one of the following behaviours:\n"\
      "\tCreate: #{@shell.valid_c_behaviours}\n"\
      "\tAlter/Modify: #{@shell.valid_a_behaviours}\n"\
      "\tDelete: #{@shell.valid_d_behaviours}\n",
      @stdout.string
    )
  end

  def test_invalid_action
    @shell.do_watch('modify pwd 5 hello.rb hello.cpp')
    assert_equal(
      "Invalid action: pwd. Please use one of: #{@shell.valid_actions}\n",
      @stdout.string
    )
  end

  def test_invalid_duration
    @shell.do_watch('modify print -1 hello.rb hello.cpp')
    assert_equal(
      "Invalid duration: -1. Please use a non-negative integer.\n",
      @stdout.string
    )
  end

  def test_invalid_filenames
    @shell.do_watch('delete print 1')
    assert_equal(
      "Please specify one or more filenames to watch.\n",
      @stdout.string
    )
  end
end
