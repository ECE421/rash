require 'cmd'

# A simple shell implementation of a file watcher program in Ruby
class FileWatcher < Cmd
  attr_reader(:valid_c_behaviours, :valid_a_behaviours, :valid_d_behaviours, :valid_actions)

  def initialize(prompt = 'rashfw> ',
                 welcome = 'Welcome to the Ruby file watcher shell.
Type `help` for a list of available commands.')
    super(prompt, welcome)

    @threads = []
    @valid_c_behaviours = %w[c create creation]
    @valid_a_behaviours = %w[a alter alteration m modify modification]
    @valid_d_behaviours = %w[d destroy destruction delete deletion]
    @valid_actions = %w[print exit]
  end

  def do_watch(args_string)
    behaviour, action, duration, *filenames = args_string.split(' ')

    puts("Invalid action: #{action}. Please use one of: #{@valid_actions}") unless @valid_actions.include?(action)
    puts("Invalid duration: #{duration}. Please use a non-negative integer.") unless duration.to_i >= 0
    puts('Please specify one or more filenames to watch.') unless filenames.length.positive?

    if @valid_c_behaviours.include?(behaviour)
      thread = Thread.start { watch_create(filenames, action, duration.to_i) }
      @threads.push(thread)
    elsif @valid_a_behaviours.include?(behaviour)
      thread = Thread.start { watch_alter(filenames, action, duration.to_i) }
      @threads.push(thread)
    elsif @valid_d_behaviours.include?(behaviour)
      thread = Thread.start { watch_delete(filenames, action, duration.to_i) }
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
    false
  end

  def help_status(_)
    false
  end

  private

  def watch_create(filenames, action, duration)
    filenames.each do |file|
      next unless File.exist?(file)

      filenames.pop(file)
    end

    created = []
    until created.eql?(filenames)
      filenames.each do |file|
        next unless File.exist?(file)

        created.push(file)
        action_after_change(action, duration)
      end
    end
  end

  def watch_alter(filenames, action, duration)
    last_snapshots = {}
    filenames.each do |file|
      abort unless File.exist?(file)
      last_snapshots[file] = File.mtime(file)
    end

    until last_snapshots.empty?
      last_snapshots.each do |file, last_snapshot|
        next unless (File.mtime(file) <=> last_snapshot).positive?

        # File has been modified
        last_snapshots.delete(file)
        action_after_change(action, duration)
      end
    end
  end

  def watch_delete(filenames, action, duration)
    filenames.each do |file|
      next if File.exist?(file)

      filenames.pop(file)
    end

    deleted = []
    until deleted.eql?(filenames)
      filenames.each do |file|
        next if File.exist?(file)

        deleted.push(file)
        action_after_change(action, duration)
      end
    end
  end

  def action_after_change(action, duration)
    sleep(duration)
    if action == 'print'
      # TODO
      puts('FILE CHANGE INFORMATION')
    elsif action == 'exit'
      do_exit('')
    end
  end

  def post_loop
    @threads.each do |thread|
      puts("Killing thread: #{thread}")
      Thread.kill(thread)
    end
  end
end
