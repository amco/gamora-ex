defmodule Gamora.Plugs.AuthenticatedUser.MockAdapterTest do
  use ExUnit.Case

  alias Plug.Conn
  alias Gamora.Plugs.AuthenticatedUser.MockAdapter

  describe "call/2" do
    test "returns the same connection" do
      conn = %Conn{}
      assert MockAdapter.call(conn, []) == {:ok, conn}
    end
  end
end
