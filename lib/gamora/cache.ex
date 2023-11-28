defmodule Gamora.Cache do
  @moduledoc """
  Default Gamora cache implementation.
  """

  use Nebulex.Cache,
    otp_app: :gamora,
    adapter: Nebulex.Adapters.Local
end
