# Gamora

> Amco OpenID Connect strategy for Überauth.

## Installation

1.  Setup your application at Amco OIDC Provider.

2.  Add `:gamora` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [
        {:gamora, "~> 0.9"}
      ]
    end
    ```

3.  Add Gamora to your Überauth configuration:

    ```elixir
    config :ueberauth, Ueberauth,
      providers: [
        amco: {Gamora, []}
      ]
    ```

4.  Update your provider configuration:

    Example 1: Using environment variables at compile time:

    ```elixir
    config :ueberauth, Gamora.OAuth,
      site: System.get_env("AMCO_IDP_URL"),
      client_id: System.get_env("AMCO_CLIENT_ID"),
      client_secret: System.get_env("AMCO_CLIENT_SECRET")
    ```

    Example 2: Using environment variables from a runtime file:

    ```elixir
    config :ueberauth, Gamora.OAuth,
      site: {System, :get_env, ["AMCO_IDP_URL"]},
      client_id: {System, :get_env, ["AMCO_CLIENT_ID"]},
      client_secret: {System, :get_env, ["AMCO_CLIENT_SECRET"]}
    ```

    Example 3: Using strings in a managed file at runtime:

    ```elixir
    config :ueberauth, Gamora.OAuth,
      site: "https://my_idp.example.com",
      client_id: "my client id",
      client_secret: "my client secret"
    ```

5.  Include the Überauth plug in your controller:

    ```elixir
    defmodule MyAppWeb.AuthController do
      use MyAppWeb, :controller

      plug Ueberauth
      ...
    end
    ```

6.  Create the request and callback routes if you haven't already:

    ```elixir
    scope "/auth", MyAppWeb do
      pipe_through :browser

      get "/logout", AuthController, :logout
      get "/:provider", AuthController, :request
      get "/:provider/callback", AuthController, :callback

      # If your app is a JSON API, you'll want to exchange the
      # authorization code using a POST request.
      post "/:provider/callback", AuthController, :callback
    end
    ```

7.  Your controller needs to implement callbacks to deal with `Ueberauth.Auth` and `Ueberauth.Failure` responses.

For an example implementation see the [Überauth Example](https://github.com/ueberauth/ueberauth_example) application.

## Callbacks

### Web-based applications

For web-based applications you should add the auth response to the
session and redirect the user to the path you want. Your callbacks in
the auth controller should look like this:

```elixir
defmodule MyAppWeb.AuthController do
  use MyAppWeb, :controller

  plug Ueberauth

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: redirect_path(conn))
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    conn
    |> put_flash(:info, "Successfully authenticated.")
    |> put_session(:access_token, auth.credentials.token)
    |> put_session(:refresh_token, auth.credentials.refresh_token)
    |> configure_session(renew: true)
    |> redirect(to: redirect_path(conn))
  end

  defp redirect_path(conn) do
    get_session(conn, :original_url) || "/"
  end
end
```

### JSON API applications

For JSON API applications you should return the access token, refresh
token and id token to the native application that is consuming the API.
Your callbacks in the auth controller should look like this:

```elixir
defmodule MyAppWeb.AuthController do
  use MyAppWeb, :controller

  plug Ueberauth

  def callback(%{assigns: %{ueberauth_failure: fails}} = conn, _params) do
    conn
    |> put_status(:unauthorized)
    |> json(%{
      message: fails.message,
      message_key: fails.message_key
    })
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    conn
    |> json(%{
      access_token: auth.credentials.token,
      id_token: auth.credentials.other["id_token"],
      refresh_token: auth.credentials.refresh_token
    })
  end

  def logout(conn, _params) do
    conn
    |> put_session(:access_token, nil)
    |> put_session(:refresh_token, nil)
    |> redirect(to: ~p"/auth/amco?max_age=0")
  end
end
```

## Protected Routes

Protecting a route means that incoming requests should contain an
access token. That access token will be validated against the
Identity Provider to verify it has not expired and is still valid.
If the access token is valid, you will have the current user in the
`conn.assigns[:current_user]` based on the claims returned by de IdP.
Otherwise the error handler will be called and the connection must be
halted.

### Web-based applications

Use the plug `Gamora.Plugs.AuthenticatedUser` in
your protected routes. This will get the access token from session
and validate it against the IDP (OIDC Identity Provider).

```elixir
defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  pipeline :protected do
    plug Gamora.Plugs.AuthenticatedUser,
      error_handler: MyAppWeb.AuthenticationErrorHandler,
      access_token_source: :session
  end

  scope "/", MyAppWeb do
    pipe_through [:browser, :protected]

    # Add your protected routes here
  end
end
```

And define your callbacks module in your application. It may look
something like the following in a phoenix application:

```elixir
defmodule MyAppWeb.AuthenticationErrorHandler do
  @behaviour Gamora.ErrorHandler

  import Plug.Conn, only: [halt: 1, put_session: 3]
  import Phoenix.Controller, only: [redirect: 2]

  @impl Gamora.ErrorHandler
  def access_token_error(conn, error) do
    conn
    |> put_session(:original_url, conn.request_path)
    |> redirect(to: "/auth/amco")
    |> halt()
  end
end
```

### JSON API applications

If your app requires json response you'll need to add `access_token_source: :headers`
to the plug options. It will get the access token from the request
header `Authorization: Bearer <access_token>`.

```elixir
defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  pipeline :protected do
    plug Gamora.Plugs.AuthenticatedUser,
      error_handler: MyAppWeb.AuthenticationErrorHandler,
      access_token_source: :headers
  end
end
```

And then update your `ErrorHandler` to response with a json. It may
look something like this:

```elixir
defmodule MyAppWeb.AuthenticationErrorHandler do
  @behaviour Gamora.ErrorHandler

  import Plug.Conn
  import Phoenix.Controller

  @impl Gamora.ErrorHandler
  def access_token_error(conn, error) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: error})
    |> halt()
  end
end
```

## Calling

Depending on the configured url you can initiate the request through:

    /auth/amco

Or with options:

    /auth/amco?scope=email%20profile&strategy=phone_number

By default the requested scope is `openid profile email`. Scope can be configured
either explicitly as a `scope` query value on the request path or in your
configuration:

```elixir
config :ueberauth, Ueberauth,
  providers: [
    amco: {Gamora, [default_scope: "openid email phone"]}
  ]
```

By default the strategy to be used is `default`. Strategy can be configured
either explicitly as a `strategy` query value on the request path or in your
configuration:

```elixir
config :ueberauth, Ueberauth,
  providers: [
    amco: {Gamora, [default_strategy: "phone_number"]}
  ]
```

By default the theme to be used is `default`. Theme can be configured
either explicitly as a `theme` query value on the request path or in your
configuration:

```elixir
config :ueberauth, Ueberauth,
  providers: [
    amco: {Gamora, [default_theme: "dark_blue"]}
  ]
```

By default the brand to be used is `amco`. Branding can be configured
either explicitly as a `branding` query value on the request path or in your
configuration:

```elixir
config :ueberauth, Ueberauth,
  providers: [
    amco: {Gamora, [default_branding: "amco"]}
  ]
```

By default prompt is not present in the authorization url. Prompt can be
configured either explicitly as a `prompt` query value on the request
path or in your configuration:

```elixir
config :ueberauth, Ueberauth,
  providers: [
    amco: {Gamora, [default_prompt: "login"]}
  ]
```

To guard against client-side request modification, it's important to still
check the domain in `info.urls[:website]` within the `Ueberauth.Auth` struct
if you want to limit sign-in to a specific domain.

## Cross-Client Identity

By default, gamora will accept only access tokens that were generating
with the `client_id` in the configuration. If access tokens coming from
other clients have to be accepted, make sure to add their client ids to
the `whitelisted_clients` config option.

```elixir
config :ueberauth, Gamora.Plugs.AuthenticatedUser,
  whitelisted_clients: ["OTHER_CLIENT_ID"]
```

## Caching

In order to avoid performing requests to the IDP on each request in the
application, it is possible to set a caching time for introspection and
userinfo endpoints. Make sure to not have a too long expiration time for
`introspect_cache_expires_in` but not too short to impact the application
performance, it is a balance. Expiration config is based on seconds.

```elixir
config :ueberauth, Gamora.Plugs.AuthenticatedUser,
  introspect_cache_expires_in: 5, # Config in seconds.
  userinfo_cache_expires_in: 600  # Config in seconds.
```

By default, Gamora uses ETS to cache data from IDP but any other cache
adapter may be implemented, for example using Redix, Nebulex, Cachex or
any other. See [adapters](https://github.com/amco/gamora-ex/blob/master/CACHE_ADAPTERS.md)
for more information. Then, specify the adapter in the configuration:

```elixir
config :ueberauth, Gamora.Plugs.AuthenticatedUser,
  cache_adapter: Gamora.Cache.Adapters.ETS
```

## Testing

In test environment you should avoid making requests to authenticate
users in protected routes. In order to do that, you can configure the
`TestAdapter` for the `AuthenticatedUser` plug in your `config/test.exs`:

```elixir
config :ueberauth, Gamora.Plugs.AuthenticatedUser,
  adapter: Gamora.Plugs.AuthenticatedUser.TestAdapter
```

## Copyright and License

Copyright (c) 2022 Amco

Released under the MIT License, which can be found in the repository in
[LICENSE](https://github.com/amco/gamora-ex/blob/master/LICENSE).
