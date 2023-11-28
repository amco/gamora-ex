# Gamora - Cache Adapters

> Examples about different cache implementation for Gamora.

## ETS

This adapter is the default in Gamora and the only step that requires
is create the ETS table in your application:

```elixir
:ets.new(:gamora, [:set, :public, :named_table])
```

## Redix

1. Add dependencies in `mix.exs`:

    ```elixir
    def deps do
      [
        {:redix, "~> 1.3"},
        {:castore, ">= 0.0.0"},
      ]
    end
    ```

2. Add Redix child in `lib/my_app/application.ex`:

    ```elixir
    def start(_type, _args) do
      children = [
        ...
        {Redix, name: :gamora}
    end
    ```

3. Create your Redix adapter in `lib/my_app/gamora/redix.ex`:

    ```elixir
    defmodule MyApp.Gamora.Redix do
      @moduledoc """
      Redix cache adapter.
      """

      @behaviour Gamora.Cache.Adapter

      @impl true
      def get(key) do
        case Redix.command(:gamora, ["GET", key]) do
          {:ok, nil} -> {:ok, nil}
          {:ok, data} -> {:ok, Jason.decode!(data)}
        end
      end

      @impl true
      def put(key, value, expires_in: expires_in) do
        {:ok, _} = Redix.command(:gamora, ["SET", key, Jason.encode!(value)])
        {:ok, _} = Redix.command(:gamora, ["EXPIRE", key, expires_in])
        {:ok, value}
      end

      @impl true
      def del(key) do
        {:ok, _data} = Redix.command(:gamora, ["DEL", key])
        {:ok, true}
      end
    end
    ```


4. Configure the Redix adapter for Gamora:

    ```elixir
    config :ueberauth, Gamora.Plugs.AuthenticatedUser,
      cache_adapter: MyApp.Gamora.Redix
    ```

## Cachex

1. Add dependencies in `mix.exs`:

    ```elixir
    def deps do
      [
        {:cachex, "~> 3.6"}
      ]
    end
    ```

2. Add Cachex child in `lib/my_app/application.ex`:

    ```elixir
    def start(_type, _args) do
      children = [
        ...
        {Cachex, name: :gamora}
    end
    ```

3. Create your Cachex adapter in `lib/my_app/gamora/cachex.ex`:

    ```elixir
    defmodule MyApp.Gamora.Cachex do
      @moduledoc """
      Cachex cache adapter.
      """

      @behaviour Gamora.Cache.Adapter

      @impl true
      def get(key) do
        Cachex.get(:gamora, key)
      end

      @impl true
      def put(key, value, expires_in: expires_in) do
        Cachex.put(:gamora, key, value, ttl: expires_in * 1_000)
        {:ok, value}
      end

      @impl true
      def del(key) do
        Cachex.del(:gamora, key)
      end
    end
    ```


4. Configure the Cachex adapter for Gamora:

    ```elixir
    config :ueberauth, Gamora.Plugs.AuthenticatedUser,
      cache_adapter: MyApp.Gamora.Cachex
    ```
