defmodule Gamora.Plugs.AuthenticatedUserTest do
  use ExUnit.Case

  alias Gamora.ErrorHandler
  alias Gamora.Plugs.AuthenticatedUser
  alias Gamora.Exceptions.{MissingErrorHandlerOption, MissingAccessTokenSourceOption}

  describe "init/1" do
    test "raise error when error_handler option is not present" do
      assert_raise MissingErrorHandlerOption, fn ->
        options = [access_token_source: :session]
        AuthenticatedUser.init(options)
      end
    end

    test "raise error when access_token_source option is not present" do
      assert_raise MissingAccessTokenSourceOption, fn ->
        options = [error_handler: ErrorHandler]
        AuthenticatedUser.init(options)
      end
    end

    test "does not raise any error when options are correct" do
      options = [
        error_handler: ErrorHandler,
        access_token_source: :session
      ]

      assert AuthenticatedUser.init(options) == options
    end
  end
end
