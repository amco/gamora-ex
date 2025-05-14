defmodule Gamora.UserTest do
  use ExUnit.Case, async: true

  alias Gamora.User

  @attributes %{
    id: 1,
    roles: %{},
    email: "darth@email.com",
    username: "darthvader",
    first_name: "Darth",
    last_name: "Vader",
    phone_number: "523344556677",
    email_verified: true,
    associated_user_id: "1234",
    phone_number_verified: true
  }

  describe "__struct__/1" do
    test "creates struct with valid attributes" do
      user = struct(User, @attributes)
      assert Map.take(user, Map.keys(@attributes)) == @attributes
    end
  end
end
