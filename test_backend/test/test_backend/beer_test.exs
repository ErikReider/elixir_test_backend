defmodule TestBackend.BeerTest do
  use ExUnit.Case, async: false
  use Plug.Test
  use TestBackend.RepoCase

  alias TestBackend.Beer

  require Logger

  @valid_params %{
    :id => 2,
    :name => "Trashy Blonde",
    :tagline => "You Know You Shouldn't",
    :description => "A titillating, neurotic, peroxide punk of a Pale Ale...",
    :brewers_tips => "Be careful not to collect too much wort from the mash...",
    :abv => 4.1,
    :image_url => "https://images.punkapi.com/v2/2.png",
    :food_pairing => [
      "Fresh crab with lemon",
      "Garlic butter dipping sauce",
      "Goats cheese salad",
      "Creamy lemon bar doused in powdered sugar"
    ]
  }

  test "the changeset invalid when empty" do
    changeset = %Beer{} |> Beer.changeset(%{})

    assert !changeset.valid?

    assert changeset.errors == [
             name: {"can't be blank", [validation: :required]},
             tagline: {"can't be blank", [validation: :required]},
             description: {"can't be blank", [validation: :required]},
             brewers_tips: {"can't be blank", [validation: :required]},
             abv: {"can't be blank", [validation: :required]},
             image_url: {"can't be blank", [validation: :required]},
             food_pairing: {"can't be blank", [validation: :required]}
           ]
  end

  test "the changeset invalid when image_url isn't correctly formatted" do
    changeset =
      %Beer{}
      |> Beer.changeset(@valid_params |> Map.update!(:image_url, fn _ -> "string" end))

    refute changeset.valid?

    assert changeset.errors == [image_url: {"has invalid format", [validation: :format]}]
  end

  test "the changeset is valid when filled" do
    changeset =
      %Beer{}
      |> Beer.changeset(@valid_params)

    assert changeset.valid?

    assert changeset.errors == []
  end

  test "converting json data to struct" do
    beer =
      Beer.get_beer_from_map(%{
        "id" => 2,
        "name" => "Trashy Blonde",
        "tagline" => "You Know You Shouldn't",
        "description" => "A titillating, neurotic, peroxide punk of a Pale Ale...",
        "brewers_tips" => "Be careful not to collect too much wort from the mash...",
        "abv" => 4.1,
        "image_url" => "https://images.punkapi.com/v2/2.png",
        "food_pairing" => [
          "Fresh crab with lemon",
          "Garlic butter dipping sauce",
          "Goats cheese salad",
          "Creamy lemon bar doused in powdered sugar"
        ]
      })

    refute beer == nil
  end

  test "encoding as JSON doesn't include ignored fields" do
    json = Jason.encode!(%Beer{}) |> Jason.decode!()

    refute json |> Map.has_key?("inserted_at")
    refute json |> Map.has_key?("updated_at")
  end
end
