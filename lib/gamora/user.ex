defmodule Gamora.User do
  @moduledoc """
  The user representation.
  """

  @type t :: %__MODULE__{
          id: String.t() | nil,
          roles: map() | nil,
          email: String.t() | nil,
          username: String.t() | nil,
          last_name: String.t() | nil,
          first_name: String.t() | nil,
          phone_number: String.t() | nil,
          email_verified: boolean() | nil,
          associated_user_id: String.t() | nil,
          phone_number_verified: boolean() | nil
        }

  defstruct id: nil,
            roles: nil,
            email: nil,
            username: nil,
            last_name: nil,
            first_name: nil,
            phone_number: nil,
            email_verified: nil,
            associated_user_id: nil,
            phone_number_verified: nil
end
