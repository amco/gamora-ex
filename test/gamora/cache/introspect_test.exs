defmodule Gamora.Cache.IntrospectTest do
  use ExUnit.Case, async: true

  import Mock

  alias Gamora.API
  alias Gamora.Cache.Introspect

  @access_token "ACCESS_TOKEN"
  @data %{active: true}

  describe "fetch/1" do
    test "returns data when is stored" do
      {:ok, @data} = Introspect.put(@access_token, @data)
      assert {:ok, @data} == Introspect.fetch(@access_token)
    end

    test "fetches data when is not stored" do
      with_mock API, introspect: fn _ -> {:ok, @data} end do
        assert {:ok, @data} == Introspect.fetch(@access_token)
      end
    end
  end

  describe "get/1" do
    test "returns data when is stored" do
      {:ok, @data} = Introspect.put(@access_token, @data)
      assert {:ok, @data} == Introspect.get(@access_token)
    end

    test "returns nil when is not stored" do
      assert {:ok, nil} == Introspect.get(@access_token)
    end
  end

  describe "put/1" do
    test "puts introspect data in the cache" do
      assert {:ok, @data} == Introspect.put(@access_token, @data)
      assert Introspect.get(@access_token) == {:ok, @data}
    end
  end
end
