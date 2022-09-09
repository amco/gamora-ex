defmodule Gamora.API do
  alias OAuth2.Response
  alias Gamora.OAuth

  @doc """
  Gets authorization's claims based on an access token. The claims will
  depend on the scope that was used in the authorization process.

  ## Parameters

    - access_token: String [Access token generated by the IdP].

  ## Examples

      iex> userinfo("bGWcAKadGrBwM...")
      {:ok, %{email: "test@example", phone_number: "+523344556677"}}

      iex> userinfo("InvalidAccessToken")
      {:error, :invalid}

  """
  def userinfo(access_token) do
    case OAuth.userinfo(access_token) do
      {:ok, %Response{status_code: 200, body: body}} -> {:ok, body}
      _ -> {:error, :access_token_invalid}
    end
  end
end
