defmodule Gamora.Exceptions.MissingAccessTokenSourceOptionTest do
  use ExUnit.Case, async: true

  alias Gamora.Exceptions.MissingAccessTokenSourceOption

  test "raises error with correct message" do
    message = "Plug option 'access_token_source' is required"

    assert_raise MissingAccessTokenSourceOption, message, fn ->
      raise MissingAccessTokenSourceOption
    end
  end
end
