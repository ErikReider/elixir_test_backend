defmodule TestBackend.CacheEntryTest do
  use ExUnit.Case, async: false
  use Plug.Test
  use TestBackend.RepoCase

  import Mock

  alias TestBackend.CacheEntry
  alias TestBackend.QueryClientMock
  alias TestBackend.Query

  require Logger

  test "the generated key is valid" do
    generated_key = CacheEntry.generate_key("Test_Beer", 100)
    assert generated_key == "9170AB843B6B430A4CF41398A0C99948"
  end

  test "the changeset invalid when empty" do
    changeset = %CacheEntry{} |> CacheEntry.changeset(%{})

    assert !changeset.valid?

    assert changeset.errors == [
             key: {"can't be blank", [validation: :required]},
             ids: {"can't be blank", [validation: :required]}
           ]
  end

  test "the changeset invalid when ids is empty" do
    changeset =
      %CacheEntry{}
      |> CacheEntry.changeset(%{
        :key => CacheEntry.generate_key("Test_Beer", 100),
        :ids => []
      })

    assert !changeset.valid?

    assert changeset.errors == [
             ids:
               {"should have at least %{count} item(s)",
                [count: 1, validation: :length, kind: :min, type: :list]}
           ]
  end

  test "the changeset is valid when filled" do
    changeset =
      %CacheEntry{}
      |> CacheEntry.changeset(%{
        :key => CacheEntry.generate_key("Test_Beer", 100),
        :ids => [1, 2, 3, 4, 5]
      })

    assert changeset.valid?

    assert changeset.errors == []
  end

  test "getting CacheEntry by args" do
    with_mock(TestBackend.QueryClient,
      fetch_data: fn q, nr -> QueryClientMock.fetch_data(q, nr) end
    ) do
      # Cache the query
      {status, beers, has_next_page, cached} = Query.get_cached("ale", 1)
      assert status == :ok
      assert length(beers) == 10
      assert has_next_page == true
      assert cached == false

      # Check if exists
      entry = CacheEntry.get_cache_entry("ale", 1)
      refute entry == nil
    end
  end
end
