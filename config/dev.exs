use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :vutuv, Vutuv.Endpoint,
  http: [port: 4000],
  url: [host: "localhost", port: 4000],
  debug_errors: true,
  code_reloader: true,
  cache_static_lookup: false,
  check_origin: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin"]],
  public_url: "http://localhost:4000",
  avatar_path: "/Users/sonya/projects/vutuv",
  symlink_path: "/var/www/yourdomainname/avatars",
  admin_name: "vutuv",
  admin_email: "info@vutuv.de",
  contact_name: "Stefan Wintermeyer",
  contact_email: "stefan.wintermeyer@amooma.de",
  organization_name: "vutuv",
  website_name: "vutuv",
  socialmedia_url: "https://twitter.com/vutuv",
  tor_host: "vutuvh2rmz3ynydm.onion"

# Watch static and templates for browser reloading.
config :vutuv, Vutuv.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development.
# Do not configure such in production as keeping
# and calculating stacktraces is usually expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :vutuv, Vutuv.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "vutuv_dev",
  hostname: "localhost",
  pool_size: 10

# Bamboo Email
config :vutuv, Vutuv.Mailer,
  adapter: Bamboo.LocalAdapter

config :quantum, cron: [
    # Every minute
    # "* * * * *": {MyApp.MyModule, :my_method}

    # Birthday reminders
    # "19 * * * *": {Vutuv.Cronjob, :send_birthday_reminders}
]
