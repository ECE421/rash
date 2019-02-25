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
    output = capture_output { @shell.cmd_loop }
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
    assert_equal(old_pwd, Dir.pwd)
  end

  def test_cd_dir
    old_pwd = Dir.pwd
    tmpdir = Dir.mktmpdir('rash_basic_shell_tests-')

    Readline.stubs(:readline)
            .returns('cd ' + tmpdir, 'exit')
    @shell.cmd_loop
    assert_not_equal(old_pwd, Dir.pwd)

    Dir.chdir(old_pwd)
    assert_equal(old_pwd, Dir.pwd)
    FileUtils.rm_rf tmpdir
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

  def test_touch
    old_pwd = Dir.pwd
    tmpdir = Dir.mktmpdir('rash_basic_shell_tests-')
    Dir.chdir(tmpdir)

    Readline.stubs(:readline)
            .returns('touch test_file', 'exit')
    @shell.cmd_loop

    assert_true(File.exist?('test_file'))

    Dir.chdir(old_pwd)
    assert_equal(old_pwd, Dir.pwd)
    FileUtils.rm_rf tmpdir
  end

  def test_cat
    test_file = create_tempfile_test_file('test_file', 'test content')

    Readline.stubs(:readline)
            .returns('cat ' + test_file.path.to_s, 'exit')
    output = capture_output do
      @shell.cmd_loop
    end

    assert_true(output.to_s.include?('test content'))
  end

  def test_cat_multiple
    test_file1 = create_tempfile_test_file('test_file1', 'test content 1')
    test_file2 = create_tempfile_test_file('test_file2', 'test content 2')

    Readline.stubs(:readline)
            .returns('cat ' + test_file1.path.to_s + ' ' + test_file2.path.to_s, 'exit')
    output = capture_output { @shell.cmd_loop }

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
    test_file = create_tempfile_test_file('test_file', 'test content')

    Readline.stubs(:readline)
            .returns('rm ' + test_file.path.to_s, 'exit')
    @shell.cmd_loop

    assert_false(File.exist?(test_file.path.to_s))
  end

  def test_rm_multiple
    test_file1 = create_tempfile_test_file('test_file1', 'test content 1')
    test_file2 = create_tempfile_test_file('test_file2', 'test content 2')

    Readline.stubs(:readline)
            .returns('rm ' + test_file1.path.to_s + ' ' + test_file2.path.to_s, 'exit')
    @shell.cmd_loop

    assert_false(File.exist?(test_file1.path.to_s))
    assert_false(File.exist?(test_file2.path.to_s))
  end

  def test_mv
    test_file1 = create_tempfile_test_file('test_file1', 'test content 1')
    test_file2 = create_tempfile_test_file('test_file2', 'test content 2')

    Readline.stubs(:readline)
            .returns('mv ' + test_file1.path.to_s + ' ' + test_file2.path.to_s, 'exit')
    @shell.cmd_loop

    assert_false(File.exist?(test_file1.path.to_s))
    assert_true(File.exist?(test_file2.path.to_s))
    assert_equal(File.open(test_file2.path.to_s).read, 'test content 1')
  end

  def test_cp
    test_file1 = create_tempfile_test_file('test_file1', 'test content 1')
    test_file2 = create_tempfile_test_file('test_file2', 'test content 2')

    Readline.stubs(:readline)
            .returns('cp ' + test_file1.path.to_s + ' ' + test_file2.path.to_s, 'exit')
    @shell.cmd_loop

    assert_true(File.exist?(test_file1.path.to_s))
    assert_true(File.exist?(test_file2.path.to_s))
    assert_equal(File.open(test_file2.path.to_s).read, 'test content 1')
  end

  def test_print
    Readline.stubs(:readline)
            .returns('print 3 message', 'exit')
    @shell.cmd_loop
    out = StringIO.new
    $stdout = out
    assert_true(Thread.main.status == 'run')
    Thread.list.each { |thr| assert_true(thr.status == 'run' || thr.status == 'sleep') }
    start = Time.now
    begin
      sleep 10
    rescue Interrupt
      assert_true(Time.now - start > 3 && Time.now - start < 3.015, Time.now - start)
      Thread.list.each { |thr| assert_true(thr.status == 'run' || thr.status == 'false') }
      assert_true($stdout.string == "\nmessage\n")
    end
    $stdout = STDOUT
  end

  def test_print_argerror1
    Readline.stubs(:readline)
            .returns('print asdfa message', 'exit')
    out = StringIO.new
    $stdout = out
    @shell.cmd_loop
    assert_equal(
      "Welcome to the Ruby basic shell.\n" \
      "Type `help` for a list of available commands.\n" \
      "Error: Provide a numeric delay to command: print\n",
      $stdout.string
    )
    $stdout = STDOUT
  end

  def test_print_argerror2
    Readline.stubs(:readline)
            .returns('print 1', 'exit')
    out = StringIO.new
    $stdout = out
    @shell.cmd_loop
    assert_equal(
      "Welcome to the Ruby basic shell.\n" \
      "Type `help` for a list of available commands.\n" \
      "Error: Provide a message to command: print\n",
      $stdout.string
    )
    $stdout = STDOUT
  end

  def test_print_securityerror
    Readline.stubs(:readline)
            .returns('print 1 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', 'exit')
    out = StringIO.new
    $stdout = out
    @shell.cmd_loop
    assert_equal(
      "Welcome to the Ruby basic shell.\n" \
      "Type `help` for a list of available commands.\n" \
      "Error: Message too long, security risk to command: print\n",
      $stdout.string
    )
    $stdout = STDOUT
  end
end
