defmodule Gamora.Cache.IntrospectTest do
  use ExUnit.Case

  import Mock

  alias Gamora.API
  alias Gamora.Cache.Introspect

  @data %{"active" => true}

  setup do
    options = [introspect_cache_expires_in: :timer.seconds(5)]
    Application.put_env(:ueberauth, Gamora.Plugs.AuthenticatedUser, options)
    {:ok, access_token: Faker.String.base64(20)}
  end

  describe "fetch/1" do
    test "returns data when is stored", %{access_token: access_token} do
      {:ok, @data} = Introspect.put(access_token, @data)
      assert {:ok, @data} == Introspect.fetch(access_token)
    end

    test "fetches data when is not stored", %{access_token: access_token} do
      {:ok, _} = Introspect.del(access_token)

      with_mock API, introspect: fn _ -> {:ok, @data} end do
        assert {:ok, @data} == Introspect.fetch(access_token)
      end
    end
  end

  describe "get/1" do
    test "returns data when is stored", %{access_token: access_token} do
      {:ok, @data} = Introspect.put(access_token, @data)
      assert {:ok, @data} == Introspect.get(access_token)
    end

    test "returns nil when is not stored", %{access_token: access_token} do
      {:ok, _} = Introspect.del(access_token)
      assert {:ok, nil} == Introspect.get(access_token)
    end
  end

  describe "put/1" do
    test "puts introspect data in the cache", %{access_token: access_token} do
      assert {:ok, @data} == Introspect.put(access_token, @data)
      assert Introspect.get(access_token) == {:ok, @data}
    end
  end

  describe "del/1" do
    test "deletes data in the cache", %{access_token: access_token} do
      assert {:ok, @data} == Introspect.put(access_token, @data)
      assert {:ok, true} == Introspect.del(access_token)
    end
  end
end
