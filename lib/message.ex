defmodule SendingProcess do
  @moduledoc """
  メッセージの転送を行うモジュール
  """

  def run(pid) do
    send(pid, :ping)
  end
end
