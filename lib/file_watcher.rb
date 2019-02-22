require_relative 'cmd'

# A simple shell implementation of a file watcher program in Ruby
class FileWatcher < Cmd
  def initialize(prompt = 'rashfw> ',
                 welcome = 'Welcome to the Ruby file watcher shell.
Type `help` for a list of available commands.')
    super(prompt, welcome)

    @threads = []

    (%w[HUP INT TERM] & Signal.list.keys).each do |signal|
      trap(signal) do
        @threads.each do |thread|
          puts("Killing thread: #{thread}")
          Thread.kill(thread)
        end
      end
    end
  end

  def do_watch(*args)
    behaviour, duration, filenames = args

    case behaviour
    when 'c' || 'create' || 'creation'
      thread = Thread.start { watch(duration, filenames) }
      puts("Started thread: #{thread}")
      @threads.append(thread)
    when 'a' || 'alter' || 'alteration' || 'm' || 'modify' || 'modification'
      thread = Thread.start { watch(duration, filenames) }
      puts("Started thread: #{thread}")
      @threads.append(thread)
    when 'd' || 'destroy' || 'destruction' || 'delete' || 'deletion'
      thread = Thread.start { watch(duration, filenames) }
      puts("Started thread: #{thread}")
      @threads.append(thread)
    else "You gave me #{behaviour} -- I have no idea what to do with that."
    end
  end

  def help_watch(_)
    puts('Usage: watch [BEHAVIOUR] [DURATION] *[FILENAMES]')
    puts('Description: Watch files denoted by FILENAMES for BEHAVIOUR.')
  end

  private

  def watch(duration, filenames)
    abort
  end
end
