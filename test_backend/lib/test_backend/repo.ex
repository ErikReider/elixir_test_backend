defmodule TestBackend.Repo do
  use Ecto.Repo,
    otp_app: :test_backend,
    adapter: Ecto.Adapters.Postgres
end
