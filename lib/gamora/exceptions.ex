defmodule Gamora.Exceptions.EmptyErrorHandler do
  defexception message: "Plug option 'error_handler' is required"
end

defmodule Gamora.Exceptions.EmptyAccessTokenSource do
  defexception message: "Plug option 'access_token_source' is required"
end

defmodule Gamora.Exceptions.MissingSiteConfiguration do
  defexception message: "Configuration option 'site' is missing"
end
