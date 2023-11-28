defmodule Gamora.Exceptions.MissingErrorHandlerOption do
  defexception message: "Plug option 'error_handler' is required"
end
