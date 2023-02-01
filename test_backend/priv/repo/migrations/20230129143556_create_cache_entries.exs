defmodule TestBackend.Repo.Migrations.CreateCacheEntries do
  use Ecto.Migration

  def change do
    create table(:cache_entries) do
      add :key, :string, null: false
      add :ids, {:array, :id}, null: false

      timestamps()
    end

    create(unique_index( :cache_entries, [:key]))
  end
end
