require 'fileutils'

require 'cmd'

# A simple bash like shell made with rash/cmd.rb
class BasicShell < Cmd
  def initialize(prompt = 'rashbs> ',
                 welcome = 'Welcome to the Ruby basic shell.
Type `help` for a list of available commands.')
    @prompt = prompt
    @welcome = welcome

    init_line_reader
  end

  # Print the current working DIRECTORY.
  def do_pwd(arg)
    puts Dir.pwd
  end

  # List the filenames within a DIRECTORY.
  #
  # If no DIRECTORY is specified the current working DIRECTORY will be listed.
  def do_ls(arg)
    if arg == ''
      puts Dir.entries(Dir.pwd)
    else
      puts Dir.entries(arg)
      # TODO: error handling
    end
  end

  # Change the current working DIRECTORY.
  def do_cd(arg)
    Dir.chdir(arg)
    # TODO: error handling
    false
  end

  # Create one or more DIRECTORIES.
  def do_mkdir(arg)
    FileUtils.mkdir arg.split(' ')
    false
  end

  # Removes one or more DIRECTORIES.
  def do_rmdir(arg)
    FileUtils.rmdir arg.split(' ')
    false
  end

  # Remove one or more FILE(s).
  def do_rm(arg)
    FileUtils.rm arg.split(' ')
    # TODO: error handling
    false
  end

  # Move a FILE to the specified path.
  def do_mv(arg)
    args = arg.split(' ')
    FileUtils.mv args[0], args[1]
    # TODO: error handling
    false
  end

  # Copy a FILE to the specified path.
  def do_cp(arg)
    args = arg.split(' ')
    FileUtils.cp args[0], args[1]
    # TODO: error handling
    false
  end

  # Concatenate FILE(s) to standard output.
  def do_cat(arg)
    args = arg.split(' ')
    args.each do |file|
      f = File.open(file)
      f.readlines.each(&method(:puts))
      f.close
    end
    false
  end

  # Update the access and modification times of each FILE to the current time.
  #
  # A FILE argument that does not exist is created empty.
  def do_touch(arg)
    args = arg.split(' ')
    args.each do |file|
      File.open(file, mode = 'w').close # rubocop:disable Lint/UselessAssignment:
    end
    false
  end

  # TODO: need some method to write to files (maybe implement the > operator?)
end
