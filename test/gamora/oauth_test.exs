defmodule Gamora.OAuthTest do
  use ExUnit.Case

  import Mock

  alias Gamora.OAuth
  alias OAuth2.Client
  alias Gamora.Exceptions.MissingSiteConfiguration

  @access_token "ACCESS_TOKEN"

  describe "client/1" do
    test "raises error when missing site configuration" do
      assert_raise MissingSiteConfiguration, fn ->
        OAuth.client([])
      end
    end

    test "does not raise error when site config is present" do
      assert OAuth.client(site: "https://myidp.example.com")
    end
  end

  describe "userinfo/2" do
    test "makes a request to userinfo endpoint in IDP" do
      opts = [site: "https://myidp.example.com"]
      client = OAuth.client(opts)
      path = "/oauth2/userinfo"
      data = %{access_token: @access_token}
      headers = [{"Content-Type", "application/json"}]

      with_mocks([
        {Client, [:passthrough],
         [post: fn ^client, ^path, ^data, ^headers -> {:ok, :response} end]}
      ]) do
        assert {:ok, :response} == OAuth.userinfo(@access_token, opts)
      end
    end
  end

  describe "introspect/2" do
    test "makes a request to introspect endpoint in IDP" do
      opts = [site: "https://myidp.example.com"]
      client = OAuth.client(opts)
      path = "/oauth2/introspect"
      headers = [{"Content-Type", "application/json"}]

      data =
        client
        |> Map.take([:client_id, :client_secret])
        |> Map.put(:token, @access_token)

      with_mocks([
        {Client, [:passthrough],
         [post: fn ^client, ^path, ^data, ^headers -> {:ok, :response} end]}
      ]) do
        assert {:ok, :response} == OAuth.introspect(@access_token, opts)
      end
    end
  end
end
