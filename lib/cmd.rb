require 'readline'

# A simple command shell implementation that is inspired from pythons cmd.py
class Cmd
  def initialize(prompt = '> ', welcome = 'Welcome to the base ruby Cmd shell', add_hist = true)
    @prompt = prompt
    @welcome = welcome
    @add_hist = add_hist

    init_line_reader
  end

  # start the command shell command input/execution loop
  def cmd_loop
    pre_loop

    puts(@welcome)

    while (input = @line_reader.readline(@prompt, @add_hist))
      init_line_reader

      manage_history(input) if @add_hist

      pre_cmd(input)

      if (command_method = get_command_method_symbol(input.split(' ')[0])).nil?
        break if on_unknown_cmd(input)
      else
        puts(input)
        return if run_command(command_method, input)
      end

      post_cmd(input)

      init_line_reader
    end

    post_loop
  end

  protected

  # setup a line reader with directory and history auto-completion
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
    @line_reader = Readline
  end

  def get_command_method_symbol(input)
    return if input.nil?

    self.class.instance_methods(false).select { |s| s.to_s.eql?('do_' + input) }[0]
  end

  def run_command(command_symbol, input)
    send(command_symbol, input)
  end

  # command history commands and management on a command
  def manage_history(input)
    # Remove blank lines from history
    Readline::HISTORY.pop if input == ''
  end

  # hook that is executed before the command input loop starts
  def pre_loop; end

  # hook that is executed after the command input loop ends
  def post_loop; end

  # hook that is executed before the command input is executed
  def pre_cmd(input); end

  # hook to execute the unknown/unsupported command input
  #
  # return true to exit the cmd_loop
  # return false to continue the cmd_loop
  def on_unknown_cmd(input)
    puts('unknown command reverting to system shell')
    # handle misc system level command
    system(input)
    false
  end

  # hook that is executed after the command input is executed
  def post_cmd(input); end

  ####################
  # Default commands #
  ####################

  # exit the cmd_loop
  # return true to exit the cmd_loop
  def do_exit(input)
    true
  end

  def do_history(input)
    puts Readline::HISTORY.to_a
  end

  # handle the cd command properly
  def do_cd(input)
    if (input != '') && (input.split('cd ')[0] == '')
      Dir.chdir(input.split('cd ')[1])
    else
      # handle misc system level command
      system(input)
    end
    false
  end
end
