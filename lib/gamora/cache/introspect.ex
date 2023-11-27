defmodule Gamora.Cache.Introspect do
  @moduledoc """
  This module that allows to get, set and fetch introspection
  data in the cache in order to improve performance.
  """

  use Gamora.Cache

  alias Gamora.API
  alias Gamora.Plugs.AuthenticatedUser

  defp fetch!(access_token) do
    case API.introspect(access_token) do
      {:ok, data} -> put(access_token, data)
      {:error, error} -> {:error, error}
    end
  end

  defp key(access_token) do
    "gamora:introspect:#{digest(access_token)}"
  end

  defp digest(access_token) do
    :crypto.hash(:sha256, access_token)
    |> Base.encode16()
    |> String.downcase()
  end

  defp expires_in do
    Application.get_env(:ueberauth, AuthenticatedUser, [])
    |> Keyword.get(:introspect_cache_expires_in, 0)
  end
end
