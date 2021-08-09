defmodule App.User.OneTimeToken do
  @prefix "App.User.OneTimeToken."

  def get(user_id) do
    Redix.command(:redix, ["GET", @prefix <> user_id])
  end

  def set(user_id, one_time_token) do
    Redix.command(:redix, ["SET", @prefix <> user_id, one_time_token])
  end
end

defmodule App.User do
  alias App.User.OneTimeToken

  @doc """
  発行したTokenと一致するか確認して、一致していればそれを無効化する
  """
  def validate_token(user_id, token) do
    case OneTimeToken.get(user_id) do
      {:ok, ^token} ->
        OneTimeToken.set(user_id, nil)
        true

      {:ok, _} ->
        false

      _ ->
        false
    end
  end
end

defmodule App.RedisClientBehavior do
  @callback get(key :: String.t()) ::
              {:ok, result :: String.t() | nil}
              | {:error, reason :: any()}
  @callback set(key :: String.t(), value :: String.t()) ::
              {:ok, ok :: String.t()}
              | {:error, reason :: any()}
end

defmodule App.Redix do
  @behaviour App.RedisClientBehavior

  def get(key) do
    Redix.command(:redix, ["GET", key])
  end

  def set(key, value) do
    Redix.command(:redix, ["SET", key, value])
  end
end

defmodule App.MockRedis do
  @behaviour App.RedisClientBehavior

  use GenServer

  def init(state), do: {:ok, state}

  def handle_call({:get, key}, _from, state) do
    case Map.fetch(state, key) do
      {:ok, result} -> {:reply, result, state}
      :error -> {:reply, nil, state}
    end
  end

  def handle_call({:set, key, value}, _from, state) do
    {:reply, "OK", Map.put(state, key, value)}
  end

  ### API
  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get(key), do: {:ok, GenServer.call(__MODULE__, {:get, key})}

  def set(key, value) do
    try do
      # TODO: validate `value` is string
      {:ok, GenServer.call(__MODULE__, {:set, key, value})}
    catch
      e -> {:error, e}
    end
  end
end
