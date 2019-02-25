require 'cmd'
require 'readline'

# A simple shell implementation of a file watcher program in Ruby
class FileWatcher < Cmd
  attr_reader(:watched_files_status, :valid_c_behaviours, :valid_a_behaviours, :valid_d_behaviours, :valid_actions)

  def initialize
    super('rashfw> ', 'Welcome to the Ruby file watcher shell. Type `help` for a list of available commands.')

    @watched_files_status = {}
    @threads = []
    @valid_c_behaviours = %w[c create creation]
    @valid_a_behaviours = %w[a alter alteration m modify modification]
    @valid_d_behaviours = %w[d destroy destruction delete deletion]
    @valid_actions = %w[print status exit]
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
