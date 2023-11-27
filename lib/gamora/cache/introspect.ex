defmodule Gamora.Cache.Introspect do
  @moduledoc """
  This module that allows to get, set and fetch introspection
  data in the cache in order to improve performance.
  """

  alias Gamora.API
  alias Gamora.Plugs.AuthenticatedUser

  @doc """
  Returns introspect data for the given access token if
  exists, otherwise it will fetch it and store it.

  ## Parameters

    - access_token: String [Access token from IDP].

  ## Examples

      iex> fetch("ACCESS_TOKEN")
      {:ok, %{"active" => true, ...}}

  """
  @spec fetch(access_token :: String.t()) :: {:ok, map()} | {:error, term()}
  def fetch(access_token) do
    case get(access_token) do
      {:ok, nil} -> fetch!(access_token)
      {:ok, data} -> {:ok, data}
    end
  end

  @doc """
  Returns introspect data for the given access token.

  ## Parameters

    - access_token: String [Access token from IDP].

  ## Examples

      iex> get("ACCESS_TOKEN")
      {:ok, nil}

      iex> get("ACCESS_TOKEN")
      {:ok, %{"active" => true, ...}}

  """
  @spec get(access_token :: String.t()) :: {:ok, nil} | {:ok, map()}
  def get(access_token) do
    Cachex.get(:gamora, key(access_token))
  end

  @doc """
  Stores introspect data for the given access token.

  ## Parameters

    - access_token: String [Access token from IDP].

  ## Examples

      iex> put("ACCESS_TOKEN", %{"active" => true, ...})
      {:ok, %{"active" => true, ...}}

  """
  @spec put(access_token :: String.t(), data :: map()) :: {:ok, map()}
  def put(access_token, data) do
    Cachex.put(:gamora, key(access_token), data, ttl: ttl())
    {:ok, data}
  end

  @doc """
  Deletes introspect cache for the given access token.

  ## Parameters

    - access_token: String [Access token from IDP].

  ## Examples

      iex> del("ACCESS_TOKEN")
      {:ok, true}

  """
  @spec del(access_token :: String.t()) :: {:ok, map()}
  def del(access_token) do
    Cachex.del(:gamora, key(access_token))
  end

  defp fetch!(access_token) do
    case API.introspect(access_token) do
      {:ok, data} -> put(access_token, data)
      {:error, error} -> {:error, error}
    end
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
