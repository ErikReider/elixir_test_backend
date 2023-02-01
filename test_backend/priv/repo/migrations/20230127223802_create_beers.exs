defmodule TestBackend.Repo.Migrations.CreateBeers do
  use Ecto.Migration

  def change do
    create table(:beers) do
      add :name, :string, null: false
      add :tagline, :string, null: false
      add :description, :text, null: false
      add :brewers_tips, :text, null: false
      add :abv, :float, null: false
      add :image_url, :string, null: false
      add :food_pairing, {:array, :string}, null: false

      timestamps()
    end
  end
end
