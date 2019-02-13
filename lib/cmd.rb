require 'readline'

# A simple command shell implementation that is inspired from pythons cmd.py
class Cmd
  def initialize(prompt = '> ', add_hist = true)
    @prompt = prompt
    @add_hist = add_hist

    init_line_reader
  end

  # start the command shell command input/execution loop
  def cmd_loop
    pre_loop

    while (input = @line_reader.readline(@prompt, @add_hist))
      init_line_reader

      pre_cmd(input)

      break if exit_cmd(input)

      manage_history(input) if @add_hist

      break if on_cmd(input)

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

  # command history commands and management on a command
  def manage_history(input)
    puts Readline::HISTORY.to_a if input == 'hist'
    # Remove blank lines from history
    Readline::HISTORY.pop if input == ''
  end

  # hook that is executed before the command input loop starts
  def pre_loop; end

  # hook that is executed after the command input loop ends
  def post_loop; end

  # hook that is executed before the command input is executed
  def pre_cmd(input); end

  # check if we should exit the cmd_loop
  # via an exit command
  # return true to exit the cmd_loop, otherwise, continue the cmd_loop
  def exit_cmd(input)
    true if input == 'exit'
  end

  # hook to execute the command input
  #
  # return true to exit the cmd_loop
  # return false to continue the cmd_loop
  def on_cmd(input)
    # handle the cd command properly
    if (input != '') && (input.split('cd ')[0] == '')
      Dir.chdir(input.split('cd ')[1])
    else
      # handle misc system level command
      system(input)
    end
    false
  end

  # hook that is executed after the command input is executed
  def post_cmd(input); end
end
