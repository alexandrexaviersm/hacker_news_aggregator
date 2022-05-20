import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :hacker_news_aggregator, HackerNewsAggregatorWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "lS3IEV4a4tuZUJ05Ln6mjpPqqxVMvEs0L1c/sTRcbv6qO2gHGV90UdcsFIZs09Yb",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :hacker_news_aggregator, :hacker_news_api,
  http_adapter: HttpAdapterMock,
  api_client: ApiBehaviourMock
