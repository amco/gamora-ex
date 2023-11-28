defmodule Gamora.Cache do
  @moduledoc """
  This module wraps common caching functions.
  """

  defmacro __using__(_args) do
    quote do
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
        adapter().get(key(access_token))
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
        adapter().put(key(access_token), data, expires_in: expires_in())
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
        adapter().del(key(access_token))
      end

      defp adapter do
        Application.get_env(:ueberauth, AuthenticatedUser, [])
        |> Keyword.get(:cache_adapter, Gamora.Cache.Adapters.ETS)
      end
    end
  end
end
