require 'readline'

# A simple command shell implementation that is inspired
# from Python's +cmd.py+.
class Cmd
  def initialize(prompt = 'rash> ',
                 welcome = 'Welcome to the base ruby Cmd shell.
Type `help` for a list of available commands.', add_hist = true)
    @prompt = prompt
    @welcome = welcome
    @add_hist = add_hist

    init_line_reader
  end

  # Setup Readline with directory and history auto-completion.
  def init_line_reader
    comp = proc do |s|
      directory_list = Dir.glob("#{s}*")
      if !directory_list.empty?
        directory_list
      elsif @add_hist
        Readline::HISTORY.grep(/^#{Regexp.escape(s)}/)
      end
    end
    Readline.completion_append_character = ' '
    Readline.completion_proc = comp
  end

  # Start the command input loop.
  def cmd_loop
    pre_loop

    puts(@welcome)

    while (input = Readline.readline(@prompt, @add_hist))
      # Remove blank lines from history if history is enabled
      Readline::HISTORY.pop if @add_hist && input == ''

      pre_cmd(input)

      if !(command_method = get_command_method_symbol(input.split(' ')[0])).nil?
        break if send(command_method, input)
      elsif on_unknown_cmd(input)
        break
      end

      post_cmd(input)

      # re-init Readline after a command has executed
      init_line_reader
    end

    post_loop
  end

  protected

  # Hook that is executed before the command input loop starts.
  def pre_loop; end

  # Hook that is executed before the command input is executed.
  def pre_cmd(input); end

  # Hook to execute the unknown/unsupported command input.
  #
  # return +true+ to exit the +cmd_loop+
  # return +false+ to continue the +cmd_loop+
  def on_unknown_cmd(input)
    puts('WARNING: Unknown command: ' + input + ' reverting to system shell')
    system(input)
    false
  end

  # Hook that is executed after the command input is executed.
  def post_cmd(input); end

  # Hook that is executed after the command input loop ends.
  def post_loop; end

  ####################
  # Default commands #
  ####################

  # Note: command method definition is similar to pythons +cmd.py+ implementation.
  # * +do_foo+ defines a command method for the command named +foo+
  # * +help_foo+ defines a help print command method for the command named +foo+
  #
  # Note: if a +do_<command_name>+ method returns true it will terminate
  # the +cmd_loop+.

  def help_exit(input)
    puts('Exit the command shell')
  end

  # Exit the +cmd_loop+ by returning +true+.
  def do_exit(input)
    true
  end

  def help_history(input)
    puts('Print the history of past issued commands')
  end

  def do_history(input)
    puts Readline::HISTORY.to_a
  end

  def help_cd(input)
    puts('Change directory to the path specified')
  end

  def do_cd(input)
    if (input != '') && (input.split('cd ')[0] == '')
      Dir.chdir(input.split('cd ')[1])
    else
      # handle misc system level command
      system(input)
    end
    false
  end

  def help_help(input)
    puts('Print the available commands within this shell.')
    puts('Use `help <command name>` to get help on a specific command')
  end

  def do_help(input)
    if input == 'help' # basic +help+ command
      puts('Use `help <command name>` to get help on a specific command')
      puts('Below is a list of available commands:')
      method_commands = self.class.instance_methods(false).select { |s| s.to_s.start_with?('do_') }
      method_commands.each do |method_symbol|
        puts(method_symbol.to_s[3..-1])
      end
    else # advanced +help <command_name>+ command
      target_command = input[5..-1]
      if !(target_command_help_method = get_command_help_method_symbol(target_command)).nil?
        send(target_command_help_method, input)
      else
        puts('No help exists for command: ' + target_command)
      end
    end
    false
  end

  ######
  # Dynamic +do_<command_name>+ and +help_<command_name>+ utilities
  ######

  # Given a command name obtain the symbol representing its
  # corresponding +do_<command_name>+ method.
  def get_command_method_symbol(input)
    return if input.nil?

    self.class.instance_methods.select { |s| s.to_s.eql?('do_' + input) }[0]
  end

  # Given a command name obtain the symbol representing its
  # corresponding +help_<command_name>+ method.
  def get_command_help_method_symbol(input)
    return if input.nil?

    self.class.instance_methods.select { |s| s.to_s.eql?('help_' + input) }[0]
  end
end
