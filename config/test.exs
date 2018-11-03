use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :vutuv, Vutuv.Endpoint,
  url: [host: "http://localhost:4000/", port: 4001],
  http: [port: 4001],
  server: false,
  public_url: "http://localhost:4000",
  admin_name: "vutuv",
  admin_email: "info@vutuv.de",
  contact_name: "Stefan Wintermeyer",
  contact_email: "stefan.wintermeyer@amooma.de",
  organization_name: "vutuv",
  website_name: "vutuv",
  socialmedia_url: "https://twitter.com/vutuv",
  tor_host: "vutuvh2rmz3ynydm.onion"

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :vutuv, Vutuv.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "vutuv_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :vutuv, Vutuv.Mailer,
  adapter: Bamboo.TestAdapter
