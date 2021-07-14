"""
USAGE:
required libs
```
defp deps do
  [
    {:joken, "~> 2.0"},
    {:jason, "~> 1.1"},
    {:httpoison, "~> 1.8"},
    {:poison, "~> 4.0"}
  ]
end
```

$ export ZOOM_API_KEY=xxx
$ export ZOOM_API_SECRET=yyy

$ iex
iex(1)> token = Zoom.Token.issue()
iex(2)> Zoom.API.issue_meeting_url(token)
#=> get meeting url :tada:
"""

defmodule Zoom.Token do
  use Joken.Config

  @impl true
  def token_config do
    default_claims(iss: System.get_env("ZOOM_API_KEY"), skip: [:aud, :jti, :nbf])
  end

  def issue() do
    signer = Joken.Signer.create("HS256", System.get_env("ZOOM_API_SECRET"))
    expire = DateTime.utc_now() |> DateTime.add(7 * 24 * 60 * 60, :second) |> DateTime.to_unix()
    {:ok, token_with_default_claims, _} = Zoom.Token.generate_and_sign(%{exp: expire}, signer)
    token_with_default_claims
  end
end


defmodule Zoom.API do
  @host "https://api.zoom.us/v2"

  @doc """
  Meeting の作成

  ## Examples

    iex> Zoom.API.issue_meeting_url(token)
    https://us05web.zoom.us/s/84838294555?zak=eyJ0eXAiOiJ…
  """
  def issue_meeting_url(token) do
    url = @host <> "/users/me/meetings"
    body = Poison.encode!(%{
      topic: "testing creating meeting",
      type: 1, # Instant Meeting
    })
    headers = ["Authorization": "Bearer #{token}", "Content-Type": "application/json"]

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 201, body: body}} ->
        Poison.decode!(body)["start_url"]
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
  end

  @doc """
  User一覧取得
  pagination 対応はしていないので、30人まで取得。
  """
  def get_users(token) do
    url = @host <> "/users?status=active&page_size=30&page_number=1"
    headers = ["Authorization": "Bearer #{token}", "Content-Type": "application/json"]

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        IO.puts body
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "Not found"
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
  end

  @doc """
  User作成
  権限がないので動作確認はできていない
  """
  def create_user(token) do
    url = @host <> "/users"
    body = Poison.encode!(%{
      action: "custCreate",
      user_info: %{
        email: "email@exaaaaaaample.com",
        type: 1,
      }
    })
    headers = ["Authorization": "Bearer #{token}", "Content-Type": "application/json"]

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        IO.puts body
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
  end
end
