require 'fileutils'

require 'sys-proctable'

require 'cmd'

# A simple bash like shell made with rash/cmd.rb
class BasicShell < Cmd
  def initialize(prompt = 'rashbs> ',
                 welcome = 'Welcome to the Ruby basic shell.
Type `help` for a list of available commands.')
    @prompt = prompt
    @welcome = welcome
    @threads = []
    init_line_reader
  end

  # Usage: pwd
  #
  # Print the current working DIRECTORY.
  def do_pwd(arg)
    puts Dir.pwd
  end

  # Usage: ls [DIRECTORY]
  #
  # List the filenames within a DIRECTORY.
  #
  # If no DIRECTORY is specified the current working DIRECTORY will be listed.
  def do_ls(arg)
    if arg == ''
      puts Dir.entries(Dir.pwd)
    else
      puts Dir.entries(arg)
      # TODO: error handling (permission/non-such)
    end
  end

  # Usage: cd [DIRECTORY]
  #
  # Change the current working DIRECTORY.
  def do_cd(arg)
    return false if arg == ''

    Dir.chdir(arg)
    # TODO: error handling (permission/non-such)
    false
  end

  # Usage: mkdir [DIRECTORIES]...
  #
  # Create one or more DIRECTORIES.
  def do_mkdir(arg)
    FileUtils.mkdir arg.split(' ')
    # TODO: error handling (permission/already exists)
    false
  end

  # Usage: rmdir [DIRECTORIES]...
  #
  # Removes one or more DIRECTORIES.
  def do_rmdir(arg)
    FileUtils.rmdir arg.split(' ')
    # TODO: error handling (permission/non-such)
    false
  end

  # Usage: rm [FILE]...
  #
  # Remove one or more FILE(s).
  def do_rm(arg)
    FileUtils.rm arg.split(' ')
    # TODO: error handling (permission/non-such)
    false
  end

  # Usage: mv SOURCE DEST
  #
  # Move a SOURCE file to the specified DEST (destination) path.
  def do_mv(arg)
    args = arg.split(' ')
    FileUtils.mv args[0], args[1]
    # TODO: error handling (permission/non-such/non-such-dir)
    false
  end

  # Usage: SOURCE DEST

  # Copy a SOURCE file to the specified DEST (destination) path.
  def do_cp(arg)
    args = arg.split(' ')
    FileUtils.cp args[0], args[1]
    # TODO: error handling (permission/non-such/non-such-dir)
    false
  end

  # Usage: cat [FILE]...
  #
  # Concatenate FILE(s) to standard output.
  def do_cat(arg)
    args = arg.split(' ')
    args.each do |filename|
      file = File.open(filename)
      # TODO: error handling (permission/non-such)
      file.readlines.each(&method(:puts))
      file.close
    end
    false
  end

  # Usage: touch [FILE]...
  #
  # Update the access and modification times of each FILE to the current time.
  #
  # A FILE argument that does not exist is created empty.
  def do_touch(arg)
    args = arg.split(' ')
    args.each do |filename|
      file = File.open(filename, mode = 'w') # rubocop:disable Lint/UselessAssignment:
      # TODO: error handling (permission/non-such/non-such-dir)
      file.close
    end
    false
  end

  # Usage: write FILE CONTENT
  #
  # Write CONTENT to the given FILE.
  #
  # A FILE argument that does not exist is created and written with CONTENT.
  def do_write(arg)
    filename = arg.split(' ')[0]
    content = arg[filename.length + 1..-1]
    file = File.open(filename, mode = 'w') # rubocop:disable Lint/UselessAssignment:
    # TODO: error handling (permission/non-such/non-such-dir)
    file.syswrite(content)
    file.close
  end

  # Usage: fork COMMAND
  #
  # Fork and run the raw system COMMAND as a detached process.
  def do_fork(arg)
    # TODO: it should really spawn a subshell of BasicShell and not go directly to system
    # TODO: though im having difficulty thinking of a nice way to do that.
    r, w = IO.pipe
    pid = Process.spawn(arg, out: w)
    Process.detach pid
    puts 'spawned process under pid: ' + pid.to_s
    w.close
    r.close
    false
  end

  # Usage: kill SIGNAL [PID]...
  #
  # Send a system specific SIGNAL to the process(es) specified by the PID(s)
  def do_kill(arg)
    signal = arg.split(' ')[0]
    pids = arg[signal.length + 1..-1].split(' ')
    pids.each do |pid|
      Process.kill(signal, pid)
      # TODO: error handling (non-such-signal/non-such-pid)
    end
    false
  end

  # Usage: ps
  #
  # Print all the currently running (and visible) processes within the system
  def do_ps(arg)
    puts Sys::ProcTable.ps
    # TODO: format better
  end

  # Usage: print SECONDS TEXT
  #
  # Wait the alloted time and then print the given message to STDOUT
  def do_print(arg)
    time = arg.split(' ')[0].to_f
    message = arg.split(' ')[1..-1].join(' ')
    @threads << Thread.new do
      # TODO: handle exceptions
      sleep time
      Thread.main.raise Interrupt
      puts "\n" + message
    end
    false
  end
end
