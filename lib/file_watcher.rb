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

  def do_watch(*args)
    behaviour, duration, filenames = args[0].split(' ')

    if @c_behaviours.include?(behaviour)
      thread = Thread.start { watch(duration, filenames) }
      puts("Started thread: #{thread}")
      @threads.push(thread)
    elsif @a_behaviours.include?(behaviour)
      thread = Thread.start { watch(duration, filenames) }
      puts("Started thread: #{thread}")
      @threads.push(thread)
    elsif @d_behaviours.include?(behaviour)
      thread = Thread.start { watch(duration, filenames) }
      puts("Started thread: #{thread}")
      @threads.push(thread)
    else
      "You gave me #{behaviour} -- I have no idea what to do with that."
    end

    false
  end

  def help_watch(_)
    puts('Usage: watch [BEHAVIOUR] [DURATION] *[FILENAMES]')
    puts('Description: Watch files denoted by FILENAMES for BEHAVIOUR.')
  end

  private

  def watch(duration, filenames)
    abort
  end

  def post_loop
    @threads.each do |thread|
      puts("Killing thread: #{thread}")
      Thread.kill(thread)
    end
  end
end
