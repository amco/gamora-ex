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
         {:ok, _} <- validate_introspection_data(token_data),
         {:ok, claims} <- Userinfo.fetch(access_token) do
      attributes = user_attributes_from_claims(claims)
      {:ok, struct(User, attributes)}
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

  defp validate_introspection_data(%{"active" => false}) do
    {:error, :access_token_invalid}
  end

  defp validate_introspection_data(%{"active" => true, "client_id" => client_id}) do
    case Enum.member?(whitelisted_clients(), client_id) do
      true -> {:ok, :valid_introspect_data}
      false -> {:error, :access_token_invalid}
    end
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
    %{
      id: claims["sub"],
      roles: claims["roles"],
      email: claims["email"],
      username: claims["username"],
      first_name: claims["given_name"],
      last_name: claims["family_name"],
      phone_number: claims["phone_number"],
      email_verified: claims["email_verified"],
      phone_number_verified: claims["phone_number_verified"]
    }
  end
end
