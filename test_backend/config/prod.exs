import Config

config :test_backend, cowboy_port: 8080

config :test_backend, :ecto_repos, [TestBackend.Repo]

config :test_backend, TestBackend.Repo,
  database: "test_backend_db",
  username: System.get_env("PGUSER") || "postgres",
  password: System.get_env("PGPASSWORD") || "postgres",
  hostname: System.get_env("PGHOST") || "localhost",
  pool_size: 10
