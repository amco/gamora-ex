defmodule Gamora.APITest do
  use ExUnit.Case

  import Mock

  alias Gamora.{API, OAuth}
  alias OAuth2.{Response, Error}
  alias Gamora.Plugs.AuthenticatedUser
  alias Gamora.Cache.{Introspect, Userinfo}

  @access_token "ACCESS_TOKEN"

  describe "userinfo/1" do
    @claims %{"sub" => 1}
    @success_response %Response{status_code: 200, body: @claims}
    @failure_response %Response{status_code: 422}

    test "returns user's claims from IDP" do
      with_mock OAuth, userinfo: fn @access_token -> {:ok, @success_response} end do
        assert {:ok, @claims} == API.userinfo(@access_token)
      end
    end

    test "returns an error when access token is invalid" do
      with_mock OAuth, userinfo: fn @access_token -> {:ok, @failure_response} end do
        assert {:error, :access_token_invalid} == API.userinfo(@access_token)
      end
    end
  end

  describe "introspect/1" do
    @data %{"active" => true}
    @success_response %Response{status_code: 200, body: @data}
    @failure_response %Response{status_code: 422}

    test "returns token information from IDP" do
      with_mock OAuth, introspect: fn @access_token -> {:ok, @success_response} end do
        assert {:ok, @data} == API.introspect(@access_token)
      end
    end

    test "returns an error when access token is invalid" do
      with_mock OAuth, introspect: fn @access_token -> {:ok, @failure_response} end do
        assert {:error, :access_token_invalid} == API.introspect(@access_token)
      end
    end
  end

  describe "revoke/1" do
    @success_response %Response{status_code: 200}
    @failure_response %Response{status_code: 401, body: %{"error" => "invalid_client"}}

    setup do
      Application.put_env(:ueberauth, AuthenticatedUser,
        userinfo_cache_expires_in: :timer.seconds(5),
        introspect_cache_expires_in: :timer.seconds(5)
      )
    end

    test "revokes the token and clears cached data" do
      with_mock OAuth, revoke: fn @access_token -> {:ok, @success_response} end do
        {:ok, _} = Userinfo.put(@access_token, %{"sub" => 1})
        {:ok, _} = Introspect.put(@access_token, %{"active" => true})
        assert :ok == API.revoke(@access_token)
        assert {:ok, nil} == Userinfo.get(@access_token)
        assert {:ok, nil} == Introspect.get(@access_token)
      end
    end

    test "returns the response body when IDP rejects the request" do
      with_mock OAuth, revoke: fn @access_token -> {:error, @failure_response} end do
        {:ok, _} = Userinfo.put(@access_token, %{"sub" => 1})
        assert {:error, %{"error" => "invalid_client"}} == API.revoke(@access_token)
        assert {:ok, %{"sub" => 1}} == Userinfo.get(@access_token)
      end
    end

    test "returns the reason when the request fails" do
      with_mock OAuth, revoke: fn @access_token -> {:error, %Error{reason: :econnrefused}} end do
        assert {:error, :econnrefused} == API.revoke(@access_token)
      end
    end
  end
end
