try do
  raise "Oh no!"
rescue
  e in RuntimeError -> IO.puts("An error occurred: " <> e.message)
after
  IO.puts("The end!")
end

defmodule ExampleError do
  defexception message: "an example error has occurred"
end

try do
  raise ExampleError
rescue
  e in ExampleError -> e
end

try do
  for x <- 0..10 do
    if x == 5, do: throw(x)
    IO.puts(x)
  end
catch
  x -> "Caught: #{x}"
end

try do
  exit "oh no!"
catch
  :exit, _ -> "exit blocked"
end
