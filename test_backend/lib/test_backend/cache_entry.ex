defmodule TestBackend.CacheEntry do
  use Ecto.Schema
  import Ecto.Changeset

  alias CacheEntry
  alias TestBackend.Repo
  alias TestBackend.CacheEntry

  @derive {Jason.Encoder, except: [:__meta__]}
  schema "cache_entries" do
    field(:key)
    field(:ids, {:array, :id})

    timestamps()
  end

  def changeset(cache_entry, params \\ %{}) do
    cache_entry
    |> cast(params, [:key, :ids])
    |> validate_required([:key, :ids])
    |> unique_constraint(:key)
    |> validate_length(:ids, min: 1)
  end

  def generate_key(query, page_nr) when is_bitstring(query) and is_integer(page_nr),
    do: :crypto.hash(:md5, "#{query}-#{page_nr}") |> Base.encode16()

  def get_cache_entry(query, page_nr) when is_bitstring(query) and is_integer(page_nr) do
    key = CacheEntry.generate_key(query, page_nr)
    Repo.get_by(CacheEntry, key: key)
  end
end
