# Run a Ruby built basic shell.
#
# This Library was made by:
#
# Group 4:
#   Nathan Klapstein (1449872)
#   Tony Qian (1396109)
#   Thomas Lorincz (1461567)
#   Zach Drever (1446384)
#

require_relative 'lib/basic_shell'

shell = BasicShell.new
shell.cmd_loop
