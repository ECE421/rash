require_relative 'helper'

class CmdTest < Test::Unit::TestCase
  def setup
    @shell = Cmd.new
  end

  def teardown
    # Do nothing
  end

  def test_initialization
    assert_true(@shell.is_a?(Cmd))
  end

  def test_exit
    Readline.expects(:readline)
            .returns('exit')
    @shell.cmd_loop
  end

  def test_smoke_help
    Readline.stubs(:readline)
            .returns('help', 'exit')
    @shell.cmd_loop
  end

  def test_smoke_help_methods
    Readline.stubs(:readline)
            .returns('help help', 'help history', 'help exit', 'exit')
    @shell.cmd_loop
  end

  def test_smoke_help_nonsuch
    Readline.stubs(:readline)
            .returns('help nonsuch', 'exit')
    @shell.cmd_loop
  end

  def test_smoke_history
    Readline.stubs(:readline)
            .returns('foo', 'foo', 'foo', 'history', 'exit')
    @shell.cmd_loop
  end

  def test_smoke_history_blank
    Readline.stubs(:readline)
            .returns('', '  ', '   ', 'history', 'exit')
    @shell.cmd_loop
  end

  def test_basic_shell_errors
    Readline.stubs(:readline)
            .returns('rm not_a_file', 'exit')
    @shell.cmd_loop
  end
end
