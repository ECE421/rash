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
            .returns('help help', 'help cd', 'help history', 'help exit', 'exit')
    @shell.cmd_loop
  end

  def test_smoke_help_nonsuch
    Readline.stubs(:readline)
            .returns('help nonsuch', 'exit')
    @shell.cmd_loop
  end

  def test_smoke_cd_empty
    Readline.stubs(:readline)
            .returns('cd', 'exit')
    @shell.cmd_loop
  end

  def test_smoke_cd
    Readline.stubs(:readline)
            .returns('cd .', 'exit')
    @shell.cmd_loop
  end

  def test_smoke_history
    Readline.stubs(:readline)
            .returns('foo', 'foo', 'foo', 'history', 'exit')
    @shell.cmd_loop
  end
end
