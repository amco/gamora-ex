defmodule Gamora.Exceptions.EmptyAccessTokenSourceTest do
  use ExUnit.Case, async: true

  alias Gamora.Exceptions.EmptyAccessTokenSource

  test "raises error with correct message" do
    message = "Plug option 'access_token_source' is required"

    assert_raise EmptyAccessTokenSource, message, fn ->
      raise EmptyAccessTokenSource
    end
  end
end
