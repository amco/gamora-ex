defmodule Gamora.Cache.Userinfo do
  @moduledoc """
  This module that allows to get, set and fetch user's claims
  in the cache in order to improve performance.
  """

  alias Gamora.API
  alias Gamora.Plugs.AuthenticatedUser

  @doc """
  Returns userinfo data for the given access token if
  exists, otherwise it will fetch it and store it.

  ## Parameters

    - access_token: String [Access token from IDP].

  ## Examples

      iex> fetch("ACCESS_TOKEN")
      {:ok, %{"sub" => 1, ...}}

  """
  @spec fetch(access_token :: String.t()) :: {:ok, map()} | {:error, term()}
  def fetch(access_token) do
    case get(access_token) do
      {:ok, nil} -> fetch!(access_token)
      {:ok, claims} -> {:ok, claims}
    end
  end

  @doc """
  Returns userinfo data for the given access token.

  ## Parameters

    - access_token: String [Access token from IDP].

  ## Examples

      iex> get("ACCESS_TOKEN")
      {:ok, nil}

      iex> get("ACCESS_TOKEN")
      {:ok, %{"sub" => 1, ...}}

  """
  @spec get(access_token :: String.t()) :: {:ok, nil} | {:ok, map()}
  def get(access_token) do
    Cachex.get(:gamora, key(access_token))
  end

  @doc """
  Stores userinfo data for the given access token.

  ## Parameters

    - access_token: String [Access token from IDP].

  ## Examples

      iex> put("ACCESS_TOKEN", %{"sub" => 1, ...})
      {:ok, %{"sub" => 1, ...}}

  """
  @spec put(access_token :: String.t(), claims :: map()) :: {:ok, map()}
  def put(access_token, claims) do
    Cachex.put(:gamora, key(access_token), claims, ttl: ttl())
    {:ok, claims}
  end

  defp fetch!(access_token) do
    case API.userinfo(access_token) do
      {:ok, claims} -> put(access_token, claims)
      {:error, error} -> {:error, error}
    end
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
