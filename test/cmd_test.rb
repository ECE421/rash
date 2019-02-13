require_relative 'test_helper'
require_relative '../lib/cmd'

class CmdTest < Test::Unit::TestCase
  def setup
    # Do nothing
  end

  def teardown
    # Do nothing
  end

  def test_initialization
    shell = Cmd.new
    assert_true(shell.is_a?(Cmd))
  end
end
