require 'fileutils'

require 'sys-proctable'

require 'cmd'

# A simple bash like shell made with rash/cmd.rb
class BasicShell < Cmd
  MAX_PRINT_SIZE = 100

  attr_reader(:watched_files_status, :valid_c_behaviours, :valid_a_behaviours, :valid_d_behaviours, :valid_actions)

  def initialize
    super('rashbs> ', 'Welcome to the Ruby basic shell. Type `help` for a list of available commands.')

    @watched_files_status = {}
    @threads = []
    @valid_c_behaviours = %w[c create creation]
    @valid_a_behaviours = %w[a alter alteration m modify modification]
    @valid_d_behaviours = %w[d destroy destruction delete deletion]
    @valid_actions = %w[print status exit]
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
    end
  end

  # Usage: cd [DIRECTORY]
  #
  # Change the current working DIRECTORY.
  def do_cd(arg)
    return false if arg == ''

    Dir.chdir(arg)
    false
  end

  # Usage: mkdir [DIRECTORIES]...
  #
  # Create one or more DIRECTORIES.
  def do_mkdir(arg)
    FileUtils.mkdir arg.split(' ')
    false
  end

  # Usage: rmdir [DIRECTORIES]...
  #
  # Removes one or more DIRECTORIES.
  def do_rmdir(arg)
    FileUtils.rmdir arg.split(' ')
    false
  end

  # Usage: rm [FILE]...
  #
  # Remove one or more FILE(s).
  def do_rm(arg)
    FileUtils.rm arg.split(' ')
    false
  end

  # Usage: mv SOURCE DEST
  #
  # Move a SOURCE file to the specified DEST (destination) path.
  def do_mv(arg)
    args = arg.split(' ')
    FileUtils.mv args[0], args[1]
    false
  end

  # Usage: SOURCE DEST

  # Copy a SOURCE file to the specified DEST (destination) path.
  def do_cp(arg)
    args = arg.split(' ')
    FileUtils.cp args[0], args[1]
    false
  end

  # Usage: cat [FILE]...
  #
  # Concatenate FILE(s) to standard output.
  def do_cat(arg)
    args = arg.split(' ')
    args.each do |filename|
      file = File.open(filename)
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
    file.syswrite(content)
    file.close
  end

  # Usage: fork COMMAND
  #
  # Fork and run the raw system COMMAND as a detached process.
  def do_fork(arg)
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
    end
    false
  end

  # Usage: ps
  #
  # Print all the currently running (and visible) processes within the system
  def do_ps(arg)
    puts Sys::ProcTable.ps
  end

  # Usage: print SECONDS TEXT
  #
  # Wait the alloted time and then print the given message to STDOUT
  def do_print(arg)
    time = arg.split(' ')[0]
    message = arg.split(' ')[1..-1]

    raise ArgumentError, 'Error: Provide a numeric delay to command: print' unless /\A\d+\z/ =~ time
    raise ArgumentError, 'Error: Provide a message to command: print' if message.empty?
    raise SecurityError, 'Error: Message too long, security risk to command: print' if message.join(' ').size > MAX_PRINT_SIZE

    @threads << Thread.new do
      sleep time.to_f
      puts "\n" + message.join(' ')
      print(@prompt)
    end
    false
  end

  def do_watch(args_string)
    behaviour, action, duration, *filenames = args_string.split(' ')

    unless @valid_actions.include?(action)
      puts("Invalid action: #{action}. Please use one of: #{@valid_actions}")
      return false
    end

    begin
      unless Float(duration) >= 0
        puts("Invalid duration: #{duration}. Please use a non-negative float.")
        return false
      end
    rescue ArgumentError
      puts("Invalid duration: #{duration}. Please use a non-negative float.")
      return false
    end

    unless filenames.length.positive?
      puts('Please specify one or more filenames to watch.')
      return false
    end

    if @valid_c_behaviours.include?(behaviour)
      thread = Thread.start { watch_create(filenames, action, Float(duration)) }
      @threads.push(thread)
    elsif @valid_a_behaviours.include?(behaviour)
      thread = Thread.start { watch_alter(filenames, action, Float(duration)) }
      @threads.push(thread)
    elsif @valid_d_behaviours.include?(behaviour)
      thread = Thread.start { watch_delete(filenames, action, Float(duration)) }
      @threads.push(thread)
    else
      puts("Invalid behaviour: #{behaviour}. Please use one of the following behaviours:")
      puts("\tCreate: #{@valid_c_behaviours}")
      puts("\tAlter/Modify: #{@valid_a_behaviours}")
      puts("\tDelete: #{@valid_d_behaviours}")
    end

    false
  end

  def help_watch(_)
    puts('Usage: watch [BEHAVIOUR] [ACTION] [DURATION] [*FILENAMES]')
    puts('Description: Watch files denoted by FILENAMES for BEHAVIOUR.')
    puts('BEHAVIOUR:')
    puts("\tCreate: #{@valid_c_behaviours}")
    puts("\tAlter/Modify: #{@valid_a_behaviours}")
    puts("\tDelete: #{@valid_d_behaviours}")
    puts('ACTION:')
    puts("\t#{@valid_actions}")
    puts('DURATION:')
    puts("\tAny non-negative integer.")
    puts('*FILENAMES:')
    puts("\tA space-separated list of files to watch.")
  end

  def do_status(_)
    @watched_files_status.each do |filename, status|
      puts("#{filename}: #{status}")
    end

    false
  end

  def help_status(_)
    puts('Usage: status')
    puts('Description: Prints the status of all watched files.')
  end

  private

  def watch_create(filenames, action, duration)
    created = []
    filenames.each do |file|
      @watched_files_status[file] = 'File not created yet.'
      next unless File.exist?(file)

      created.push(file)
      @watched_files_status[file] = "File already existed. Last modified: #{File.mtime(file)}"
    end

    until created.eql?(filenames)
      filenames.each do |file|
        next unless File.exist?(file) && !created.include?(file)

        created.push(file)
        @watched_files_status[file] = "File created at: #{File.mtime(file)}"
        action_after_change(action, duration)
      end
    end
  end

  def watch_alter(filenames, action, duration)
    modified = []
    last_snapshots = {}
    filenames.each do |file|
      if File.exist?(file)
        last_snapshots[file] = File.mtime(file)
        @watched_files_status[file] = "File not modified since latest watch dispatched. File last modified at: #{File.mtime(file)}"
      else
        @watched_files_status[file] = 'File does not exist.'
      end
    end

    until modified.eql?(last_snapshots.keys)
      last_snapshots.each do |file, last_snapshot|
        next unless (File.mtime(file) <=> last_snapshot).positive?

        modified.push(file)
        @watched_files_status[file] = "File last modified at: #{File.mtime(file)}"
        action_after_change(action, duration)
      rescue SystemCallError
        next
      end
    end
  end

  def watch_delete(filenames, action, duration)
    deleted = []
    filenames.each do |file|
      @watched_files_status[file] = 'File currently exists.'
      next if File.exist?(file)

      @watched_files_status[file] = 'File did not exist when command was issued.'
      deleted.push(file)
    end

    until deleted.eql?(filenames)
      filenames.each do |file|
        next if File.exist?(file)

        deleted.push(file)
        @watched_files_status[file] = "File deleted at: #{Time.now}"
        action_after_change(action, duration)
      end
    end
  end

  def action_after_change(action, duration)
    sleep(duration)
    if %w[print status].include?(action)
      puts

      @watched_files_status.each do |filename, status|
        puts("#{filename}: #{status}")
      end

      print(@prompt)
    elsif action == 'exit'
      abort
    end
  end

  def post_loop
    @threads.each do |thread|
      Thread.kill(thread)
    end
  end
end
