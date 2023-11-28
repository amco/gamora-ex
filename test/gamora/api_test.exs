defmodule Gamora.APITest do
  use ExUnit.Case

  import Mock

  alias OAuth2.Response
  alias Gamora.{API, OAuth}

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
end
