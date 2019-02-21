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

  # Usage: pwd
  #
  # Print the current working DIRECTORY.
  def do_pwd(arg)
    puts Dir.pwd
  end

  # Usage: ls [DIRECTORY]
  #
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

  # Usage: cd DIRECTORY
  #
  # Change the current working DIRECTORY.
  def do_cd(arg)
    Dir.chdir(arg)
    # TODO: error handling
    false
  end

  # Usage: mkdir [DIRECTORIES]...
  #
  # Create one or more DIRECTORIES.
  def do_mkdir(arg)
    FileUtils.mkdir arg.split(' ')
    false
  end

  # Usage: rmdir [DIRECTORIES]...
  #
  # Removes one or more DIRECTORIES.
  def do_rmdir(arg)
    FileUtils.rmdir arg.split(' ')
    false
  end

  # Usage: rm [FILE]...
  #
  # Remove one or more FILE(s).
  def do_rm(arg)
    FileUtils.rm arg.split(' ')
    # TODO: error handling
    false
  end

  # Usage: mv SOURCE DEST
  #
  # Move a SOURCE file to the specified DEST (destination) path.
  def do_mv(arg)
    args = arg.split(' ')
    FileUtils.mv args[0], args[1]
    # TODO: error handling
    false
  end

  # Usage: SOURCE DEST

  # Copy a SOURCE file to the specified DEST (destination) path.
  def do_cp(arg)
    args = arg.split(' ')
    FileUtils.cp args[0], args[1]
    # TODO: error handling
    false
  end

  # Usage: cat [FILE]...
  #
  # Concatenate FILE(s) to standard output.
  def do_cat(arg)
    args = arg.split(' ')
    args.each do |filename|
      file = File.open(filename)
      file.readlines.each(&method(:puts))
      file.close
    end
    false
  end

  # Usage: touch [FILE]...
  #
  # Update the access and modification times of each FILE to the current time.
  #
  # A FILE argument that does not exist is created empty.
  def do_touch(arg)
    args = arg.split(' ')
    args.each do |filename|
      file = File.open(filename, mode = 'w') # rubocop:disable Lint/UselessAssignment:
      file.close
    end
    false
  end

  # Usage: write FILE CONTENT
  #
  # Write CONTENT to the given FILE.
  #
  # A FILE argument that does not exist is created and written with CONTENT.
  def do_write(arg)
    filename = arg.split(' ')[0]
    content = arg[filename.length + 1..-1]
    file = File.open(filename, mode = 'w') # rubocop:disable Lint/UselessAssignment:
    file.syswrite(content)
    file.close
  end
end