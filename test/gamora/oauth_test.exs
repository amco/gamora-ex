
defmodule Gamora.OAuthTest do
  use ExUnit.Case

  alias Gamora.OAuth
  alias Gamora.Exceptions.MissingSiteConfiguration

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
end
