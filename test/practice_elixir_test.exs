defmodule PracticeElixirTest do
  use ExUnit.Case
  doctest PracticeElixir

  setup_all do
    {:ok, recipient: :world}
  end

  test "greets the world" do
    assert PracticeElixir.hello() == :world
    refute PracticeElixir.hello() == "world"
  end

  test "greets", state do
    assert PracticeElixir.hello() == state[:recipient]
  end
end

defmodule OutputTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  test "outputs Hello World" do
    assert capture_io(fn -> IO.puts("Hello World") end) == "Hello World\n"
  end
end
