defmodule Gamora.Cache.Introspect do
  @moduledoc """
  """

  alias Gamora.API
  alias Gamora.Plugs.AuthenticatedUser

  def get(access_token) do
    case Cachex.get!(:gamora, key(access_token)) do
      nil -> fetch(access_token)
      data -> {:ok, data}
    end
  end

  def fetch(access_token) do
    case API.introspect(access_token) do
      {:ok, data} -> set(access_token, data)
      {:error, error} -> {:error, error}
    end
  end

  def set(access_token, data) do
    Cachex.put(:gamora, key(access_token), data, ttl: ttl())
    {:ok, data}
  end

  defp key(access_token) do
    "introspect:#{digest(access_token)}"
  end

  defp digest(access_token) do
    :crypto.hash(:sha256, access_token)
    |> Base.encode16()
    |> String.downcase()
  end

  defp ttl do
    Application.get_env(:ueberauth, AuthenticatedUser, [])
    |> Keyword.get(:introspect_cache_expires_in, :timer.seconds(0))
  end
end
