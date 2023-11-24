defmodule Gamora.Exceptions.EmptyErrorHandlerTest do
  use ExUnit.Case, async: true

  alias Gamora.Exceptions.EmptyErrorHandler

  test "raises error with correct message" do
    message = "Plug option 'error_handler' is required"

    assert_raise EmptyErrorHandler, message, fn ->
      raise EmptyErrorHandler
    end
  end
end
