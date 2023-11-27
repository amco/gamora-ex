defmodule Gamora.Plugs.AuthenticatedUserTest do
  use ExUnit.Case

  import Mock

  alias Plug.Conn
  alias Gamora.Plugs.AuthenticatedUser
  alias Gamora.{User, TestErrorHandler}
  alias Gamora.Plugs.AuthenticatedUser.IdpAdapter
  alias Gamora.Exceptions.{MissingErrorHandlerOption, MissingAccessTokenSourceOption}

  describe "init/1" do
    test "raise error when error_handler option is not present" do
      assert_raise MissingErrorHandlerOption, fn ->
        options = [access_token_source: :session]
        AuthenticatedUser.init(options)
      end
    end

    test "raise error when access_token_source option is not present" do
      assert_raise MissingAccessTokenSourceOption, fn ->
        options = [error_handler: TestErrorHandler]
        AuthenticatedUser.init(options)
      end
    end

    test "does not raise any error when options are correct" do
      options = [
        error_handler: TestErrorHandler,
        access_token_source: :session
      ]

      assert AuthenticatedUser.init(options) == options
    end
  end

  describe "call/2" do
    @user %User{id: 1}

    @options [
      error_handler: TestErrorHandler,
      access_token_source: :session
    ]

    setup do
      {:ok, conn: Plug.Test.init_test_session(%Conn{}, %{})}
    end

    test "assigns current_user when adapter returns a user", %{conn: conn} do
      with_mock IdpAdapter, call: fn ^conn, @options -> {:ok, @user} end do
        assert %Conn{} = conn = AuthenticatedUser.call(conn, @options)
        assert conn.assigns.current_user == @user
      end
    end

    test "forwards conn when adapter returns a conn", %{conn: conn} do
      with_mock IdpAdapter, call: fn ^conn, @options -> {:ok, conn} end do
        assert %Conn{} = new_conn = AuthenticatedUser.call(conn, @options)
        assert new_conn == conn
      end
    end

    test "calls ErrorHandler when adapter returns an error", %{conn: conn} do
      with_mock IdpAdapter, call: fn ^conn, @options -> {:error, :access_token_invalid} end do
        assert {:error, {conn, :access_token_invalid}} == AuthenticatedUser.call(conn, @options)
      end
    end
  end
end
