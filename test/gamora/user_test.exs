defmodule Gamora.UserTest do
  use ExUnit.Case, async: true

  alias Gamora.User

  @attributes %{
    id: 1,
    roles: %{},
    email: "darth@email.com",
    first_name: "Darth",
    last_name: "Vader",
    phone_number: "523344556677",
    email_verified: true,
    phone_number_verified: true
  }

  describe "__struct__/1" do
    test "creates struct with valid attributes" do
      user = User.__struct__(@attributes)
      assert Map.take(user, Map.keys(@attributes)) == @attributes
    end

    test "raises error with invalid attributes" do
      assert_raise KeyError, fn ->
        User.__struct__(%{invalid: 1})
      end
    end
  end
end
