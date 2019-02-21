# A simple shell implementation of a file watcher program in Ruby
class FileWatcher < Cmd
  def initialize(prompt = 'rashfw> ',
                 welcome = 'Welcome to the Ruby file watcher shell.
Type `help` for a list of available commands.')
    @prompt = prompt
    @welcome = welcome

    init_line_reader
  end

  ####################
  # Default commands #
  ####################

  # Note: command method definition is similar to pythons +cmd.py+ implementation.
  # * +do_foo+ defines a command method for the command named +foo+
  # * +help_foo+ defines a help print command method for the command named +foo+
  #
  # Note: If no +help_foo+ help print command method is defined, the documentation
  # comments above the +do_foo+ command method will be used as a help message.
  # If no such documentation comment exists for the +do_foo+ command method,
  # a message stating that no help is available for the command +foo+ will be
  # displayed.
  #
  # Note: If a +do_<command_name>+ command method returns +true+ it will terminate
  # the +cmd_loop+.

  def help_help(input)
    puts('Print the available commands within this shell.')
    puts('Use `help <command name>` to get help on a specific command')
  end

  def do_help(input)
    if input == 'help' # basic +help+ command
      puts('Use `help <command_name>` to get help on a specific command')
      puts('Below is a list of available commands:')
      method_commands = self.class.instance_methods(false).select { |s| s.to_s.start_with?('do_') }
      method_commands.each do |method_symbol|
        puts(method_symbol.to_s[3..-1])
      end
    else # advanced +help <command_name>+ command
      target_command = input[5..-1]
      if !(target_command_help_method = get_command_help_method_symbol(target_command)).nil?
        send(target_command_help_method, input)
      elsif !(target_command_method_help_comment = get_command_method_help_comment(target_command)).nil?
        puts(target_command_method_help_comment)
      else
        puts('No help exists for command: ' + target_command)
      end
    end
    false
  end

  # Exit the command shell.
  def do_exit(input)
    true
  end

  # Print the history of past issued commands.
  def do_history(input)
    puts(Readline::HISTORY.to_a)
  end
end
