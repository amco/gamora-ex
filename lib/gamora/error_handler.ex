defmodule Gamora.ErrorHandler do
  @moduledoc """
  The error handler behaviour.
  """

  @type conn :: Plug.Conn
  @type response :: map()

  @doc """
  This callbacks is called when the access token couldn't be validated
  or the OpenID Connect Provider returned that it was invalid or expired.
  """
  @callback access_token_error(conn, response) :: conn
end
