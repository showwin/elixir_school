defmodule KVS do
  use GenServer

  @doc """
  GenServer.init/1 コールバック
  """
  def init(state), do: {:ok, state}

  @doc """
  GenServer.handle_call/3 コールバック
  """
  def handle_call({:get, key}, _from, state) do
    {:reply, Map.fetch(state, key), state}
  end

  def handle_call({:set, key, value}, _from, state) do
    {:reply, Map.put(state, key, value), state}
  end

  ## クライアント側API

  @doc """
  キューを開始してリンクする。
  これはヘルパー関数
  """
  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get(key), do: GenServer.call(__MODULE__, {:get, key})
  def set(key, value), do: GenServer.call(__MODULE__, {:set, key, value})
end
