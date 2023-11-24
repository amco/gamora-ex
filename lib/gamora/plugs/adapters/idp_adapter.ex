defmodule Gamora.Plugs.AuthenticatedUser.IdpAdapter do
  @moduledoc """
  This adapter is in charge to verify and validate the access token
  provided in the request against the OpenID Connect Provider.
  It will try to get the access token from headers for json requests,
  otherwise from cookies.

  If the access token is valid, the current user will be assigned to the
  connection and the request will continue as normal. In the other hand,
  it will call the access_token_error function in the response handler.
  """

  alias Plug.Conn
  alias Gamora.User
  alias Gamora.Plugs.AuthenticatedUser
  alias Gamora.Cache.{Userinfo, Introspect}

  def call(%Conn{} = conn, opts) do
    with source <- Keyword.get(opts, :access_token_source),
         {:ok, access_token} <- get_access_token(conn, source),
         {:ok, token_data} <- Introspect.fetch(access_token),
         true <- valid_introspection_data?(token_data),
         {:ok, claims} <- Userinfo.fetch(access_token) do
      attributes = user_attributes_from_claims(claims)
      {:ok, struct(User, attributes)}
    else
      {:error, error} -> {:error, error}
    end
  end

  defp get_access_token(%Conn{} = conn, :headers) do
    case Conn.get_req_header(conn, "authorization") do
      ["Bearer " <> access_token] -> {:ok, access_token}
      _ -> {:error, :access_token_required}
    end
  end

  defp get_access_token(%Conn{} = conn, :session) do
    case Conn.get_session(conn, :access_token) do
      nil -> {:error, :access_token_required}
      token -> {:ok, token}
    end
  end

  defp valid_introspection_data?(%{"active" => active, "client_id" => client_id}) do
    active && Enum.member?(whitelisted_clients(), client_id)
  end

  defp whitelisted_clients do
    Application.get_env(:ueberauth, AuthenticatedUser, [])
    |> Keyword.get(:whitelisted_clients, [])
    |> Kernel.++([application_client_id()])
  end

  defp application_client_id do
    Application.get_env(:ueberauth, Gamora.OAuth, [])
    |> Keyword.get(:client_id)
  end

  defp user_attributes_from_claims(claims) do
    Enum.reduce(claims, %{}, fn {claim, value}, attrs ->
      case claim do
        "sub" -> Map.put(attrs, :id, value)
        "roles" -> Map.put(attrs, :roles, value)
        "email" -> Map.put(attrs, :email, value)
        "given_name" -> Map.put(attrs, :first_name, value)
        "family_name" -> Map.put(attrs, :last_name, value)
        "phone_number" -> Map.put(attrs, :phone_number, value)
        "email_verified" -> Map.put(attrs, :email_verified, value)
        "phone_number_verified" -> Map.put(attrs, :phone_number_verified, value)
        _ -> attrs
      end
    end)
  end
end
