defmodule Gamora.Exceptions.MissingAccessTokenSourceOption do
  defexception message: "Plug option 'access_token_source' is required"
end
