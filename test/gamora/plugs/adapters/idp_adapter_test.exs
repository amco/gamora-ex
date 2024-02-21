defmodule Gamora.Plugs.AuthenticatedUser.IdpAdapterTest do
  use ExUnit.Case

  import Mock

  alias Plug.Conn
  alias Gamora.Cache.{Userinfo, Introspect}
  alias Gamora.Plugs.AuthenticatedUser.IdpAdapter

  setup do
    {:ok, %{conn: %Conn{}}}
  end

  @userinfo_response %{
    "sub" => 1,
    "roles" => %{},
    "email" => "darth@email.com",
    "given_name" => "Darth",
    "family_name" => "Vader",
    "phone_number" => "+523344556677",
    "email_verified" => true,
    "phone_number_verified" => true
  }

  @introspect_response %{
    "active" => true,
    "client_id" => "CLIENT_ID"
  }

  setup do
    Application.put_env(:ueberauth, Gamora.OAuth, client_id: "CLIENT_ID")
    :ok
  end

  describe "call/2" do
    test "when source is session and access token is not present", %{conn: conn} do
      with_mock Conn, get_session: fn _, _ -> nil end do
        error = {:error, :access_token_required}
        assert IdpAdapter.call(conn, access_token_source: :session) == error
      end
    end

    test "when source is headers and access token is not present", %{conn: conn} do
      error = {:error, :access_token_required}
      assert IdpAdapter.call(conn, access_token_source: :headers) == error
    end

    test "when access token is in the session and it is valid", %{conn: conn} do
      with_mocks [
        {Introspect, [], fetch: fn _ -> {:ok, @introspect_response} end},
        {Userinfo, [], fetch: fn _ -> {:ok, @userinfo_response} end},
        {Conn, [], get_session: fn _, _ -> "XXXX" end}
      ] do
        {:ok, user} = IdpAdapter.call(conn, access_token_source: :session)
        assert user.id == @userinfo_response["sub"]
        assert user.roles == @userinfo_response["roles"]
        assert user.email == @userinfo_response["email"]
        assert user.first_name == @userinfo_response["given_name"]
        assert user.last_name == @userinfo_response["family_name"]
        assert user.phone_number == @userinfo_response["phone_number"]
        assert user.email_verified == @userinfo_response["email_verified"]
        assert user.phone_number_verified == @userinfo_response["phone_number_verified"]
      end
    end

    test "when access token is in the session but is not active", %{conn: conn} do
      with_mocks [
        {Introspect, [], fetch: fn _ -> {:ok, %{"active" => false}} end},
        {Conn, [], get_session: fn _, _ -> "XXXX" end}
      ] do
        error = {:error, :access_token_invalid}
        assert IdpAdapter.call(conn, access_token_source: :session) == error
      end
    end

    test "when access token is in the headers and it is valid", %{conn: conn} do
      with_mocks [
        {Introspect, [], fetch: fn _ -> {:ok, @introspect_response} end},
        {Userinfo, [], fetch: fn _ -> {:ok, @userinfo_response} end}
      ] do
        conn = conn |> Conn.put_req_header("authorization", "Bearer XXX")
        {:ok, user} = IdpAdapter.call(conn, access_token_source: :headers)
        assert user.id == @userinfo_response["sub"]
        assert user.roles == @userinfo_response["roles"]
        assert user.email == @userinfo_response["email"]
        assert user.first_name == @userinfo_response["given_name"]
        assert user.last_name == @userinfo_response["family_name"]
        assert user.phone_number == @userinfo_response["phone_number"]
        assert user.email_verified == @userinfo_response["email_verified"]
        assert user.phone_number_verified == @userinfo_response["phone_number_verified"]
      end
    end

    test "when access token is in the headers but is not active", %{conn: conn} do
      with_mocks [
        {Introspect, [], fetch: fn _ -> {:ok, %{"active" => false}} end}
      ] do
        error = {:error, :access_token_invalid}
        conn = conn |> Conn.put_req_header("authorization", "Bearer XXX")
        assert IdpAdapter.call(conn, access_token_source: :headers) == error
      end
    end
  end
end
