defmodule Gamora.Cache.Userinfo do
  @moduledoc """
  This module that allows to get, set and fetch user's claims
  in the cache in order to improve performance.
  """

  use Gamora.Cache.Actions

  alias Gamora.API
  alias Gamora.Plugs.AuthenticatedUser

  defp fetch!(access_token) do
    case API.userinfo(access_token) do
      {:ok, claims} -> put(access_token, claims)
      {:error, error} -> {:error, error}
    end
  end

  defp key(access_token) do
    "gamora:userinfo:#{digest(access_token)}"
  end

  defp digest(access_token) do
    :crypto.hash(:sha256, access_token)
    |> Base.encode16()
    |> String.downcase()
  end

  defp expires_in do
    Application.get_env(:ueberauth, AuthenticatedUser, [])
    |> Keyword.get(:userinfo_cache_expires_in, :timer.seconds(60))
  end
end
