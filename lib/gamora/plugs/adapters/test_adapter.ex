defmodule Gamora.Plugs.AuthenticatedUser.TestAdapter do
  @moduledoc """
  This adapter just returns the connection. The purpose of this module
  is to be used in test environment to avoid making request to the
  identity provider to authenticate users.
  """

  alias Plug.Conn
  alias Gamora.User

  def call(%Conn{} = conn, _opts) do
    with nil <- user_from_assigns(conn),
         nil <- user_from_cookies(conn) do
      {:ok, conn}
    else
      %User{} = user -> {:ok, user}
    end
  end

  defp user_from_assigns(%Conn{} = conn) do
    case conn.assigns[:current_user] do
      %User{} = user -> user
      _ -> nil
    end
  end

  defp user_from_cookies(%Conn{} = conn) do
    with conn <- Conn.fetch_cookies(conn),
         data <- conn.cookies["current_user"],
         true <- data != nil do
      attrs = Jason.decode!(data, keys: :atoms)
      struct(User, attrs)
    else
      _ -> nil
    end
  end
end
