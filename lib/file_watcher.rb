require_relative 'cmd'

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
    behaviour, duration, *filenames = args_string.split(' ')

    if @c_behaviours.include?(behaviour)
      thread = Thread.start { watch_create(duration.to_i, filenames) }
      puts("Started thread: #{thread}")
      @threads.push(thread)
    elsif @a_behaviours.include?(behaviour)
      thread = Thread.start { watch_alter(duration.to_i, filenames) }
      puts("Started thread: #{thread}")
      @threads.push(thread)
    elsif @d_behaviours.include?(behaviour)
      thread = Thread.start { watch_delete(duration.to_i, filenames) }
      puts("Started thread: #{thread}")
      @threads.push(thread)
    else
      puts("Invalid behaviour #{behaviour}. Please use one of the following behaviours:")
      puts("\tCreate: #{@c_behaviours}")
      puts("\tAlter/Modify: #{@a_behaviours}")
      puts("\tDelete: #{@d_behaviours}")
    end

    false
  end

  def help_watch(_)
    puts('Usage: watch [BEHAVIOUR] [DURATION] *[FILENAMES]')
    puts('Description: Watch files denoted by FILENAMES for BEHAVIOUR.')
  end

  private

  def watch_create(duration, filenames)
    while true
      filenames.each do |_|
        nil
      end
    end
  end

  def watch_alter(duration, filenames)
    while true
      filenames.each do |_|
        nil
      end
    end
  end

  def watch_delete(duration, filenames)
    while true
      filenames.each do |_|
        nil
      end
    end
  end

  def action_after_change(duration, action = "puts('Hello, security vulnerability!')")
    sleep(duration)
    proc {
      $SAFE = 4
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
