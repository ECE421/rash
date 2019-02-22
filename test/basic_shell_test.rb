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
    Dir.chdir(old_pwd)
    assert_equal(old_pwd, Dir.pwd)
    FileUtils.rm_rf dir
  end

  def test_smoke_fork
    Readline.stubs(:readline)
            .returns('fork echo foobar', 'exit')
    @shell.cmd_loop
  end

  def test_smoke_ps
    Readline.stubs(:readline)
            .returns('ps', 'exit')
    @shell.cmd_loop
  end

  def test_touch
    old_pwd = Dir.pwd
    dir = Dir.mktmpdir('rash_basic_shell_tests-')
    Dir.chdir(dir)
    assert_equal(dir, Dir.pwd)
    Readline.stubs(:readline)
            .returns('touch testfile', 'exit')
    @shell.cmd_loop
    assert_true(File.exist?('testfile'))
    Dir.chdir(old_pwd)
    assert_equal(old_pwd, Dir.pwd)
    FileUtils.rm_rf dir
  end

  def create_tempfile_test_file(name, content)
    tempfile = Tempfile.new(name)
    tfd = tempfile.open
    tfd.write(content)
    tfd.close
    assert_true(File.exist?(tempfile.path.to_s))
    tempfile
  end

  def test_cat
    tempfile = create_tempfile_test_file('testfile', 'test content')
    Readline.stubs(:readline)
            .returns('cat ' + tempfile.path.to_s, 'exit')

    output = capture_output do
      @shell.cmd_loop
    end

    puts(output.to_s)
    assert_true(output.to_s.include?('test content'))
  end

  def test_cat_multiple
    tempfile1 = create_tempfile_test_file('testfile1', 'test content 1')
    tempfile2 = create_tempfile_test_file('testfile2', 'test content 2')

    Readline.stubs(:readline)
            .returns('cat ' + tempfile1.path.to_s + ' ' + tempfile2.path.to_s, 'exit')

    output = capture_output do
      @shell.cmd_loop
    end

    puts(output.to_s)
    assert_true(output.to_s.include?('test content 1'))
    assert_true(output.to_s.include?('test content 2'))
  end

  def test_smoke_ls_null
    Readline.stubs(:readline)
            .returns('ls', 'ls ', 'ls  ', 'exit')
    @shell.cmd_loop
  end

  def test_smoke_ls
    Readline.stubs(:readline)
            .returns('ls .', 'exit')
    @shell.cmd_loop
  end

  def test_rm
    tempfile = create_tempfile_test_file('testfile', 'test content')
    Readline.stubs(:readline)
            .returns('rm ' + tempfile.path.to_s, 'exit')

    @shell.cmd_loop

    assert_false(File.exist?(tempfile.path.to_s))
  end

  def test_rm_multiple
    tempfile1 = create_tempfile_test_file('testfile1', 'test content 1')
    tempfile2 = create_tempfile_test_file('testfile2', 'test content 2')

    Readline.stubs(:readline)
            .returns('rm ' + tempfile1.path.to_s + ' ' + tempfile2.path.to_s, 'exit')

    @shell.cmd_loop

    assert_false(File.exist?(tempfile1.path.to_s))
    assert_false(File.exist?(tempfile2.path.to_s))
  end
end
