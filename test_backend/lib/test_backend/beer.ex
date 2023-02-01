defmodule TestBackend.Beer do
  use Ecto.Schema
  import Ecto.Changeset
  alias TestBackend.Beer

  @derive {Jason.Encoder, except: [:__meta__]}
  schema "beers" do
    field(:name)
    field(:tagline)
    field(:description)
    field(:brewers_tips)
    # alcohol by volume
    field(:abv, :float)
    field(:image_url)
    field(:food_pairing, {:array, :string})

    timestamps()
  end

  def changeset(beer, params \\ %{}) do
    beer
    |> cast(params, [
      :name,
      :tagline,
      :description,
      :brewers_tips,
      :abv,
      :image_url,
      :food_pairing
    ])
    |> validate_required([
      :name,
      :tagline,
      :description,
      :brewers_tips,
      :abv,
      :image_url,
      :food_pairing
    ])
    |> validate_format(:image_url, ~r/^https:\/\/.+$/)
  end

  def get_beer_from_map(node) when is_map(node) do
    time = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    with %{"id" => id} <- node,
         (%Ecto.Changeset{} = changeset) = Beer.changeset(%Beer{}, node),
         true <- changeset.valid? do
      changeset.changes
      |> Map.put(:id, id)
      |> Map.put(:inserted_at, time)
      |> Map.put(:updated_at, time)
    else
      _ -> nil
    end
  end
end
