import Config

config :test_backend, cowboy_port: 8081

config :test_backend, :ecto_repos, [TestBackend.Repo]

config :test_backend, TestBackend.Repo,
  database: "test_backend_db_test",
  username: System.get_env("PGUSER") || "postgres",
  password: System.get_env("PGPASSWORD") || "postgres",
  hostname: System.get_env("PGHOST") || "localhost",
  stacktrace: true,
  log: false,
  pool: Ecto.Adapters.SQL.Sandbox
