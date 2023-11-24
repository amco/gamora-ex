defmodule Gamora.Cache.Userinfo do
  @moduledoc """
  """

  alias Gamora.API
  alias Gamora.Plugs.AuthenticatedUser

  def get(access_token) do
    case Cachex.get!(:gamora, key(access_token)) do
      nil -> fetch(access_token)
      claims -> {:ok, claims}
    end
  end

  def fetch(access_token) do
    case API.userinfo(access_token) do
      {:ok, claims} -> set(access_token, claims)
      {:error, error} -> {:error, error}
    end
  end

  def set(access_token, claims) do
    Cachex.put(:gamora, key(access_token), claims, ttl: ttl())
    {:ok, claims}
  end

  defp key(access_token) do
    "userinfo:#{digest(access_token)}"
  end

  defp digest(access_token) do
    :crypto.hash(:sha256, access_token)
    |> Base.encode16()
    |> String.downcase()
  end

  defp ttl do
    Application.get_env(:ueberauth, AuthenticatedUser, [])
    |> Keyword.get(:userinfo_cache_expires_in, :timer.seconds(60))
  end
end
