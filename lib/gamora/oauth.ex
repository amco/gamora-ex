defmodule Gamora.OAuth do
  @moduledoc """
  OAuth2 for Amco.
  Add `:client_id` and `:client_secret` to your configuration:
      config :ueberauth, Gamora.OAuth,
        client_id: System.get_env("AMCO_APP_ID"),
        client_secret: System.get_env("AMCO_APP_SECRET")
  """
  use OAuth2.Strategy

  alias Gamora.Exceptions

  @defaults [
    strategy: __MODULE__,
    token_url: "/oauth2/token",
    authorize_url: "/oauth2/authorize"
  ]

  @userinfo_path "/oauth2/userinfo"
  @introspect_path "/oauth2/introspect"

  @doc """
  Construct a client for requests to Amco.
  This will be setup automatically for you in `Gamora`.
  These options are only useful for usage outside the normal callback phase
  of Ueberauth.
  """
  def client(opts \\ []) do
    config = Application.get_env(:ueberauth, __MODULE__, [])

    opts =
      @defaults
      |> Keyword.merge(config)
      |> Keyword.merge(opts)

    json_library = Ueberauth.json_library()

    unless Keyword.has_key?(opts, :site) do
      raise Exceptions.MissingSiteConfiguration
    end

    opts
    |> OAuth2.Client.new()
    |> OAuth2.Client.put_serializer("application/json", json_library)
  end

  def userinfo(access_token, opts \\ []) do
    client = client(opts)

    data =
      :ueberauth
      |> Application.get_env(__MODULE__, [])
      |> Keyword.take([:skip_fetch_roles])
      |> Keyword.put(:access_token, access_token)
      |> Enum.into(%{})

    OAuth2.Client.post(client, @userinfo_path, data, [
      {"Content-Type", "application/json"}
    ])
  end

  def introspect(access_token, opts \\ []) do
    client = client(opts)

    data =
      client
      |> Map.take([:client_id, :client_secret])
      |> Map.put(:token, access_token)

    OAuth2.Client.post(client, @introspect_path, data, [
      {"Content-Type", "application/json"}
    ])
  end

  @doc """
  Provides the authorize url for the request phase of Ueberauth.
  No need to call this usually.
  """
  def authorize_url!(params \\ [], opts \\ []) do
    opts
    |> client()
    |> OAuth2.Client.authorize_url!(params)
  end

  def get_access_token(params \\ [], opts \\ []) do
    opts
    |> client()
    |> OAuth2.Client.get_token(params)
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_param("client_secret", client.client_secret)
    |> put_header("Accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end
end
