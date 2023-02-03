defmodule TestBackend.Query do
  require Logger

  import Ecto.Query

  alias Ecto.Multi
  alias TestBackend.Repo
  alias TestBackend.CacheEntry
  alias TestBackend.Beer

  @doc """
    search: The search query
    page_nr: The current page_nr (starts at index 1)
  """
  def query(search, page_nr) when is_bitstring(search) and is_bitstring(page_nr) do
    search = search |> String.trim() |> String.downcase()

    case Integer.parse(page_nr) do
      {page_nr, _remainder} ->
        cond do
          String.length(search) == 0 -> {:query_error, "Query cannot be empty"}
          page_nr == 0 -> {:query_error, "Page number must start with 0"}
          true -> get_cached(search, page_nr)
        end

      _ ->
        {:query_error, "Could not parse Integer from \"#{page_nr}\""}
    end
  end

  @doc """
  Grabs the cached data or the latest data from punkapi if there's no cache
  """
  def get_cached(query, page_nr) when is_bitstring(query) and is_integer(page_nr) do
    Logger.debug("Caching #{query}, page: #{page_nr}")

    beers =
      for page_nr <- [page_nr, page_nr + 1] do
        entry = CacheEntry.get_cache_entry(query, page_nr)
        now = NaiveDateTime.utc_now()

        cond do
          # Invalidate cache that's 1 hour and older
          entry != nil && NaiveDateTime.diff(now, entry.updated_at, :hour) == 0 ->
            # Grabs the cached data
            Logger.debug(
              "Fetching cache for page #{page_nr}, #{entry.id} #{entry.key}, ids: #{entry.ids}"
            )

            {Repo.all(from b in Beer, where: b.id in ^entry.ids), true}

          # NOTE: possible improvement would be to invalidate and remove each
          # beer that's only assosiated with this cache entry
          true ->
            # Grabs the latest data from punkapi
            Logger.debug("Fetching the latest data for page #{page_nr}")
            get_latest_data(query, page_nr)
        end
      end

    {current_page, cached} = List.first(beers, {[], false})
    {next_page, _cached} = List.last(beers, {[], false})

    {
      :ok,
      # Beers
      current_page,
      # If there's a next page
      length(next_page) > 0,
      # If the result was cached or not
      cached
    }
  rescue
    error ->
      Logger.error(error)
      {:error, error}
  end

  @doc """
  Grabs the latest data from punkapi
  """
  def get_latest_data(query, page_nr) do
    result = TestBackend.QueryClient.fetch_data(query, page_nr)

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- result do
      beers =
        case body |> Jason.decode() do
          {:ok, data} -> List.wrap(data)
          _ -> throw("Beers JSON is not valid")
        end
        |> Enum.map(fn node -> Beer.get_beer_from_map(node) end)
        |> Enum.filter(fn node -> !is_nil(node) end)

      cache_entry =
        CacheEntry.changeset(%CacheEntry{}, %{
          :key => CacheEntry.generate_key(query, page_nr),
          :ids => Enum.map(beers, fn b -> b.id end)
        })

      Multi.new()
      |> Multi.insert(:insert_cache_entry, cache_entry,
        on_conflict: :replace_all,
        conflict_target: [:key],
        returning: false
      )
      |> Multi.insert_all(:insert_all_beers, Beer, beers,
        on_conflict: :replace_all,
        conflict_target: [:id],
        returning: false
      )
      |> Repo.transaction()

      {beers, false}
    else
      _ -> {[], false}
    end
  end
end

defmodule TestBackend.QueryClient do
  @per_page 10

  def fetch_data(query, page_nr) do
    HTTPoison.get(
      "https://api.punkapi.com/v2/beers" <>
        "?beer_name=#{query}" <>
        "&page=#{page_nr}" <>
        "&per_page=#{@per_page}"
    )
  end
end
