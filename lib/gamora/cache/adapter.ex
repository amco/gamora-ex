defmodule Gamora.Cache.Adapter do
  @moduledoc """
  This behaviour encapsulates the required callbacks to
  implement a cache adapter.
  """

  @doc """
  Gets data in a cache key.
  """
  @callback get(key :: String.t()) :: {:ok, nil} | {:ok, map()}

  @doc """
  Puts data in a cache key.
  """
  @callback put(key :: String.t(), value :: map(), opts :: keyword()) :: {:ok, map()}

  @doc """
  Deletes data in a cache key.
  """
  @callback del(key :: String.t()) :: {:ok, true}
end
