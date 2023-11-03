defmodule Gamora.User do
  @type t :: %__MODULE__{
          id: binary | nil,
          email: binary | nil,
          last_name: binary | nil,
          first_name: binary | nil,
          phone_number: binary | nil,
          email_verified: boolean | nil,
          phone_number_verified: boolean | nil
        }

  defstruct id: nil,
            email: nil,
            last_name: nil,
            first_name: nil,
            phone_number: nil,
            email_verified: nil,
            phone_number_verified: nil
end
