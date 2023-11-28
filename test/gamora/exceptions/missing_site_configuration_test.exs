defmodule Gamora.Exceptions.MissingSiteConfigurationTest do
  use ExUnit.Case, async: true

  alias Gamora.Exceptions.MissingSiteConfiguration

  test "raises error with correct message" do
    message = "Configuration option 'site' is missing"

    assert_raise MissingSiteConfiguration, message, fn ->
      raise MissingSiteConfiguration
    end
  end
end
