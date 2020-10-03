# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :tesla, adapter: Tesla.Adapter.Mint

config :hotex,
  ecto_repos: [Hotex.Repo]

# Configures the endpoint
config :hotex, HotexWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "UMKAvZpnEXQa2Fvah3KQ7ihJ+jieM7rW1SQ/9M5JaMDdcP6TXzlFpduafSmYhKKF",
  render_errors: [view: HotexWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Hotex.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "aX4rU+72"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
