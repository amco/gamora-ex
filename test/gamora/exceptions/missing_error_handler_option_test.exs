defmodule Gamora.Exceptions.MissingErrorHandlerOptionTest do
  use ExUnit.Case, async: true

  alias Gamora.Exceptions.MissingErrorHandlerOption

  test "raises error with correct message" do
    message = "Plug option 'error_handler' is required"

    assert_raise MissingErrorHandlerOption, message, fn ->
      raise MissingErrorHandlerOption
    end
  end
end
