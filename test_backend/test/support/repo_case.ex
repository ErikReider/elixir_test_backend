defmodule TestBackend.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias TestBackend.Repo

      import Ecto
      import Ecto.Query
      import TestBackend.RepoCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(TestBackend.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(TestBackend.Repo, {:shared, self()})
    end

    :ok
  end
end
