require_relative 'helper'
require 'tmpdir'

class BasicShellTest < Test::Unit::TestCase
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

  # Smokes that ensure functionality from Cmd is maintained
  # TODO: is there a better way to test this with inheritance?

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

  # new functionality within BasicShell

  def test_pwd
    pwd = Dir.pwd
    Readline.stubs(:readline)
            .returns('pwd', 'exit')

    output = capture_output do
      @shell.cmd_loop
    end
    assert_true(output.to_s.include?(pwd))
  end

  def test_cd_null
    old_pwd = Dir.pwd
    Readline.stubs(:readline)
            .returns('cd  ', 'cd ', 'cd', 'exit')
    @shell.cmd_loop
    new_pwd = Dir.pwd
    assert_equal(old_pwd, new_pwd)
  end

  def test_cd_pwd
    old_pwd = Dir.pwd
    Readline.stubs(:readline)
            .returns('cd .', 'exit')
    @shell.cmd_loop
    new_pwd = Dir.pwd
    assert_equal(old_pwd, new_pwd)
  end

  def test_cd_dir
    old_pwd = Dir.pwd
    dir = Dir.mktmpdir('rash_basic_shell_tests-')
    Readline.stubs(:readline)
            .returns('cd ' + dir, 'exit')
    @shell.cmd_loop
    new_pwd = Dir.pwd
    assert_not_equal(old_pwd, new_pwd)
    FileUtils.rm_rf dir
  end
end
