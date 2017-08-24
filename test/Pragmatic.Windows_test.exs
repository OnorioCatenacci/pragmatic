defmodule Pragmatic.Windows.Test do
  use ExUnit.Case
  doctest Pragmatic.Windows
  import Pragmatic.Windows

  test "Check short names works as expected" do
    assert {:ok,_} = check_short_name_support()
  end
end
