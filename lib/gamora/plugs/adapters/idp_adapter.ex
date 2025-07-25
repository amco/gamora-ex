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
  alias Gamora.Cache.{Userinfo, Introspect}

  def call(%Conn{} = conn, opts) do
    with {:ok, :pending_user} <- get_current_user(conn),
         source <- Keyword.get(opts, :access_token_source),
         {:ok, access_token} <- get_access_token(conn, source),
         {:ok, token_data} <- Introspect.fetch(access_token),
         {:ok, _} <- validate_introspection_data(token_data),
         {:ok, claims} <- Userinfo.fetch(access_token) do
      attributes = user_attributes_from_claims(claims)
      {:ok, struct(User, attributes)}
    end
  end

  # TO-DO - This supports legacy scenarios and should be removed when
  # the whole Amco ecosystem gets fully migrated to IDP.
  defp get_current_user(%Conn{} = conn) do
    case conn.assigns[:current_user] do
      nil -> {:ok, :pending_user}
      user -> {:ok, user}
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

  defp validate_introspection_data(%{"active" => active}) do
    case active do
      true -> {:ok, :valid_introspect_data}
      false -> {:error, :access_token_invalid}
    end
  end

  defp user_attributes_from_claims(claims) do
    %{
      id: claims["sub"],
      roles: claims["roles"],
      email: claims["email"],
      username: claims["username"],
      first_name: claims["given_name"],
      last_name: claims["family_name"],
      birth_day: claims["birth_day"],
      birth_month: claims["birth_month"],
      phone_number: claims["phone_number"],
      email_verified: claims["email_verified"],
      national_id: claims["national_id"],
      national_id_country: claims["national_id_country"],
      associated_user_id: claims["associated_user_id"],
      phone_number_verified: claims["phone_number_verified"]
    }
  end
end
