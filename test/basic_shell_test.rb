require_relative 'helper'

class CmdTest < Test::Unit::TestCase
  def setup
    @shell = BasicShell.new
  end

  def teardown
    # Do nothing
  end

  def test_initialization
    assert_true(@shell.is_a?(Cmd))
    assert_true(@shell.is_a?(BasicShell))
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

  def test_pwd
    pwd = Dir.pwd
    Readline.stubs(:readline)
            .returns('pwd', 'exit')

    output = capture_output do
      @shell.cmd_loop
    end
    assert_true(output.to_s.include?(pwd))
  end
end
