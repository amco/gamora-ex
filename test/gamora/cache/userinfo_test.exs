defmodule Gamora.Cache.UserinfoTest do
  use ExUnit.Case

  import Mock

  alias Gamora.API
  alias Gamora.Cache.Userinfo
  alias Gamora.Plugs.AuthenticatedUser

  @data %{"sub" => 1}

  setup do
    options = [userinfo_cache_expires_in: 5]
    Application.put_env(:ueberauth, AuthenticatedUser, options)
    {:ok, access_token: Faker.String.base64(20)}
  end

  describe "fetch/1" do
    test "returns data when is cached", %{access_token: access_token} do
      {:ok, @data} = Userinfo.put(access_token, @data)
      assert {:ok, @data} == Userinfo.fetch(access_token)
    end

    test "fetches data when is not cached", %{access_token: access_token} do
      {:ok, _} = Userinfo.del(access_token)

      with_mock API, userinfo: fn _ -> {:ok, @data} end do
        assert {:ok, @data} == Userinfo.fetch(access_token)
      end
    end

    test "fetches data when cached data has expired", %{access_token: access_token} do
      options = [userinfo_cache_expires_in: 0]
      Application.put_env(:ueberauth, AuthenticatedUser, options)
      {:ok, @data} = Userinfo.put(access_token, @data)

      with_mock API, userinfo: fn _ -> {:ok, @data} end do
        assert {:ok, @data} == Userinfo.fetch(access_token)
      end
    end
  end

  describe "get/1" do
    test "returns data when is cached", %{access_token: access_token} do
      {:ok, @data} = Userinfo.put(access_token, @data)
      assert {:ok, @data} == Userinfo.get(access_token)
    end

    test "returns nil when data is not cached", %{access_token: access_token} do
      {:ok, _} = Userinfo.del(access_token)
      assert {:ok, nil} == Userinfo.get(access_token)
    end

    test "returns nil when cached data has expired", %{access_token: access_token} do
      options = [userinfo_cache_expires_in: 0]
      Application.put_env(:ueberauth, AuthenticatedUser, options)
      {:ok, @data} = Userinfo.put(access_token, @data)
      assert {:ok, nil} == Userinfo.get(access_token)
    end
  end

  describe "put/2" do
    test "puts data in the cache", %{access_token: access_token} do
      assert {:ok, @data} == Userinfo.put(access_token, @data)
      assert Userinfo.get(access_token) == {:ok, @data}
    end
  end

  describe "del/1" do
    test "deletes entry in the cache", %{access_token: access_token} do
      assert {:ok, @data} == Userinfo.put(access_token, @data)
      assert {:ok, true} == Userinfo.del(access_token)
    end
  end
end
