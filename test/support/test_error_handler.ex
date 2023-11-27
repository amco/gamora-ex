defmodule Gamora.TestErrorHandler do
  @moduledoc """
  Error handler module for testing purposes.
  """

  @behaviour Gamora.ErrorHandler

  @impl Gamora.ErrorHandler
  def access_token_error(conn, error) do
    {:error, {conn, error}}
  end
end
