defmodule Mix.Tasks.Hello do
  use Mix.Task

  @shortdoc "Simaply calls the PracticeElixir.hello_world/0 function"
  def run(_) do
    # Mix.Task.run("app.start")

    PracticeElixir.hello_world()
  end
end
