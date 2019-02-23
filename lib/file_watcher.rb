require 'cmd'

# A simple shell implementation of a file watcher program in Ruby
class FileWatcher < Cmd
  def initialize(prompt = 'rashfw> ',
                 welcome = 'Welcome to the Ruby file watcher shell.
Type `help` for a list of available commands.')
    super(prompt, welcome)

    @threads = []
    @c_behaviours = %w[c create creation]
    @a_behaviours = %w[a alter alteration m modify modification]
    @d_behaviours = %w[d destroy destruction delete deletion]
  end

  def do_watch(args_string)
    behaviour, action, duration, *filenames = args_string.split(' ')

    if @c_behaviours.include?(behaviour)
      thread = Thread.start { watch_create(filenames, action, duration.to_i) }
      @threads.push(thread)
    elsif @a_behaviours.include?(behaviour)
      thread = Thread.start { watch_alter(filenames, action, duration.to_i) }
      @threads.push(thread)
    elsif @d_behaviours.include?(behaviour)
      thread = Thread.start { watch_delete(filenames, action, duration.to_i) }
      @threads.push(thread)
    else
      puts("Invalid behaviour: '#{behaviour}'. Please use watch with one of the following behaviours:")
      puts("\tCreate: #{@c_behaviours}")
      puts("\tAlter/Modify: #{@a_behaviours}")
      puts("\tDelete: #{@d_behaviours}")
    end

    false
  end

  def help_watch(_)
    puts('Usage: watch [BEHAVIOUR] [ACTION] [DURATION] *[FILENAMES]')
    puts('Description: Watch files denoted by FILENAMES for BEHAVIOUR.')
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
    # Hello, security vulnerability!
    sleep(duration)
    proc {
      eval(action)
    }.call
  end

  def post_loop
    @threads.each do |thread|
      puts("Killing thread: #{thread}")
      Thread.kill(thread)
    end
  end
end
