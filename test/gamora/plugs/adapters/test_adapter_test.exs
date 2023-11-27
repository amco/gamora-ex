defmodule Gamora.Plugs.AuthenticatedUser.TestAdapterTest do
  use ExUnit.Case, async: true

  alias Plug.Conn
  alias Gamora.User
  alias Gamora.Plugs.AuthenticatedUser.TestAdapter

  describe "call/2" do
    test "returns the user when is present in conn assigns" do
      user = %User{id: 1, email: "test@email.com"}
      conn = %Conn{assigns: %{current_user: user}}
      assert TestAdapter.call(conn, []) == {:ok, user}
    end

    test "returns the user when is present in cookies" do
      attrs = %{id: 1, email: "test@email.com"}
      conn = Conn.put_resp_cookie(%Conn{}, "current_user", Jason.encode!(attrs))
      assert {:ok, %User{} = user} = TestAdapter.call(conn, [])
      assert user.email == attrs.email
      assert user.id == attrs.id
    end

    test "returns the same connection when current user is not present" do
      conn = %Conn{}
      assert TestAdapter.call(conn, []) == {:ok, conn}
    end
  end
end
