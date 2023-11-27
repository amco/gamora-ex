defmodule Gamora.Cache.Adapters.Cachex do
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
