defmodule Gamora.Cache do
  @moduledoc false

  use Nebulex.Cache,
    otp_app: :gamora,
    adapter: Nebulex.Adapters.Local
end
