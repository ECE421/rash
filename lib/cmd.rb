require 'readline'
require 'method_source'

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
  # Note: If no +help_foo+ help print command method is defined,
  # the documentation comments above the +do_foo+ command method will
  # be used as a help message. If no such documentation comment
  # exists for the +do_foo+ command method, a message stating that
  # no help is available for the command +foo+ will be displayed.
  #
  # Note: If a +do_<command_name>+ method returns +true+ it will terminate
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

  # Change directory to the path specified.
  def do_cd(input)
    if (input != '') && (input.split('cd ')[0] == '')
      Dir.chdir(input.split('cd ')[1])
    else
      # handle misc system level command
      system(input)
    end
    false
  end

  ######
  # Dynamic +do_<command_name>+ and +help_<command_name>+ utilities
  ######

  # Given a +command_name+ obtain the symbol representing its
  # corresponding +do_<command_name>+ command method.
  def get_command_method_symbol(command_name)
    return if command_name.nil?

    self.class.instance_methods.select { |s| s.to_s.eql?('do_' + command_name) }[0]
  end

  # Given a +command_name+ obtain the symbol representing its
  # corresponding +help_<command_name>+ help print command method.
  def get_command_help_method_symbol(command_name)
    return if command_name.nil?

    self.class.instance_methods.select { |s| s.to_s.eql?('help_' + command_name) }[0]
  end

  # Given a +command_name+ obtain the documentation comments
  # corresponding to +do_<command_name>+ command method.
  def get_command_method_help_comment(command_name)
    return if command_name.nil?
    return if (command_symbol = get_command_method_symbol(command_name)).nil?

    raw_comment = self.class.instance_method(command_symbol).comment
    raw_comment = clean_help_comment(raw_comment)
    return nil if raw_comment == ''

    raw_comment
  end

  # Clean a command method comment string to be more console readable.
  def clean_help_comment(raw_comment)
    raw_comment.gsub!(/^# /, '')
    raw_comment.strip
  end
end
