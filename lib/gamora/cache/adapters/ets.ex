defmodule Gamora.Cache.Adapters.ETS do
  @moduledoc """
  ETS cache adapter.
  """

  @behaviour Gamora.Cache.Adapter

  @impl true
  def get(key) do
    with [{_key, data, expires}] <- :ets.lookup(:gamora, key),
         true <- :erlang.system_time(:second) < expires do
      {:ok, data}
    else
      [] ->
        {:ok, nil}

      false ->
        del(key)
        {:ok, nil}
    end
  end

  @impl true
  def put(key, value, expires_in: expires_in) do
    expires = :erlang.system_time(:second) + expires_in
    :ets.insert(:gamora, {key, value, expires})
    {:ok, value}
  end

  @impl true
  def del(key) do
    :ets.delete(:gamora, key)
    {:ok, true}
  end
end
