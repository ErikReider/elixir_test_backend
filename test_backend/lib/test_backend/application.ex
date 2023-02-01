defmodule TestBackend.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: TestBackend.Router, port: cowboy_port()},
      TestBackend.Repo,
      TestBackend.Cacher
      # Starts a worker by calling: TestBackend.Worker.start_link(arg)
      # {TestBackend.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TestBackend.Supervisor]

    IO.puts("Starting Web Server")

    Supervisor.start_link(children, opts)
    
  end

  defp cowboy_port(), do: Application.get_env(:test_backend, :cowboy_port, 8080)
end
