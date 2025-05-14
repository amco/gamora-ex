# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v0.15.0

* Enhancements:
  * Add support for `allow_amco_badge` param in the authorization url.

## v0.14.0

* Enhancements:
  * Add option to skip fetching roles when asking for userinfo.

## v0.13.0

* Enhancements:
  * Add support for `associated_user_id` claim.

## v0.12.2

* Bug fixes:
  * Fix else clause in TestAdapter.

## v0.12.1

* Enhancements:
  * Add invalid and required access token cases to the TestAdapter.

## v0.12.0

* Enhancements:
  * Add support for `allow_create` param in the authorization url.

## v0.11.1

* Enhancements:
  * Remove unused alias warning in `IdpAdapter`.

## 0.11.0

* Deprecations:
  * Remove `whitelisted_clients` support.

## v0.10.0

* Enhancements:
  * Add support for `username` claim.

## v0.9.0

* Enhancements:
  * Verify access token using introspect endpoint instead userinfo.
  * Add `introspect_cache_expires_in` config to avoid hitting the IDP
    every request. Default value is `:timer.seconds(0)`.
  * New default value for `userinfo_cache_expires_in` config. Now,
    the default value is `:timer.seconds(60)`.
  * Add `whitelisted_clients` config to accept access tokens ONLY
    from trusted clients. Default value is the same client.

* Breaking changes:
  * If your application is accepting access tokens from other IDP
    clients you must set the `whitelisted_clients` config with
    the client ids that are whitelisted. Otherwise, the application
    is gonna accept access tokens ONLY from the same client id.

## v0.8.0

* Enhancements:
  * Add support for `roles` claim.

## v0.7.0

* Enhancements:
  * Add support for `email_verified` and `phone_number_verified` claims.

## v0.6.0

* Enhancements:
  * Add support for `max_age` param in the authorization url.

## v0.5.1

* Bug fixes:
  * Fix ExDocs according to the new library name.

## v0.5.0

* Enhancements:
  * Add support for `branding` param in the authorization url.

## v0.4.0

* Enhancements:
  * Add support for `theme` param in the authorization url.

## v0.3.0

* Enhancements:
  * Improve plug adapters.
  * Add IdpAdapter and MockAdapter.

## v0.2.0

* Enhancements:
  * Add Gamora.User structure to represent user claims.

## v0.1.0

* Initial version of the ueberauth strategy for amco.
