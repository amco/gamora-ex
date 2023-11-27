defmodule Gamora.Cache.Adapters.Redix do
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
