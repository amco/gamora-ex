defmodule Gamora.Cache.UserinfoTest do
  use ExUnit.Case, async: true

  import Mock

  alias Gamora.API
  alias Gamora.Cache.Userinfo

  @access_token "ACCESS_TOKEN"
  @data %{"sub" => 1}

  describe "fetch/1" do
    test "returns data when is stored" do
      {:ok, @data} = Userinfo.put(@access_token, @data)
      assert {:ok, @data} == Userinfo.fetch(@access_token)
    end

    test "fetches data when is not stored" do
      with_mock API, userinfo: fn _ -> {:ok, @data} end do
        assert {:ok, @data} == Userinfo.fetch(@access_token)
      end
    end
  end

  describe "get/1" do
    test "returns data when is stored" do
      {:ok, @data} = Userinfo.put(@access_token, @data)
      assert {:ok, @data} == Userinfo.get(@access_token)
    end

    test "returns nil when is not stored" do
      assert {:ok, nil} == Userinfo.get(@access_token)
    end
  end

  describe "put/1" do
    test "puts data in the cache" do
      assert {:ok, @data} == Userinfo.put(@access_token, @data)
      assert Userinfo.get(@access_token) == {:ok, @data}
    end
  end
end
