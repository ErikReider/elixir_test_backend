defmodule TestBackend.QueryTest do
  use ExUnit.Case, async: false
  use Plug.Test
  use TestBackend.RepoCase

  import Mock

  require Logger

  alias TestBackend.QueryClientMock
  alias TestBackend.Query

  @doc """
  Queries the DB with a mock date and time
  """
  def query_mocked_date(%NaiveDateTime{} = time) do
    with_mock(
      NaiveDateTime,
      [:passthrough],
      utc_now: fn -> time end
    ) do
      {status, beers, has_next_page, cached} = Query.query("ale", "1")
      assert status == :ok
      assert length(beers) == 10
      assert has_next_page == true
      assert cached == false

      for beer <- beers do
        assert beer.updated_at == time
      end
    end
  end

  test "Test getting the latest data" do
    with_mock(TestBackend.QueryClient,
      fetch_data: fn q, nr -> QueryClientMock.fetch_data(q, nr) end
    ) do
      {beers, cached} = Query.get_latest_data("ale", 1)

      assert length(beers) == 10
      assert cached == false
    end
  end

  test "Test getting the latest data and cached" do
    with_mock(TestBackend.QueryClient,
      fetch_data: fn q, nr -> QueryClientMock.fetch_data(q, nr) end
    ) do
      # Get fetched data
      {status, beers, has_next_page, cached} = Query.get_cached("ale", 1)
      assert status == :ok
      assert length(beers) == 10
      assert has_next_page == true
      assert cached == false

      # Get cached data
      {status, beers, has_next_page, cached} = Query.get_cached("ale", 1)
      assert status == :ok
      assert length(beers) == 10
      assert has_next_page == true
      assert cached == true
    end
  end

  test "Test query getting the latest data and cached" do
    with_mock(TestBackend.QueryClient,
      fetch_data: fn q, nr -> QueryClientMock.fetch_data(q, nr) end
    ) do
      # Get fetched data
      {status, beers, has_next_page, cached} = Query.query("ale", "1")
      assert status == :ok
      assert length(beers) == 10
      assert has_next_page == true
      assert cached == false

      # Get cached data
      {status, beers, has_next_page, cached} = Query.query("ale", "1")
      assert status == :ok
      assert length(beers) == 10
      assert has_next_page == true
      assert cached == true
    end
  end

  describe "Test query invalid parameters" do
    test "Empty query" do
      with_mock(TestBackend.QueryClient,
        fetch_data: fn q, nr -> QueryClientMock.fetch_data(q, nr) end
      ) do
        result = Query.query("", "1")

        assert match?({:query_error, "Query cannot be empty"}, result)
      end
    end

    test "less than zero page number" do
      with_mock(TestBackend.QueryClient,
        fetch_data: fn q, nr -> QueryClientMock.fetch_data(q, nr) end
      ) do
        result = Query.query("Ale", "0")

        assert match?({:query_error, "Page number must start with 0"}, result)
      end
    end

    test "Invalid page number" do
      with_mock(TestBackend.QueryClient,
        fetch_data: fn q, nr -> QueryClientMock.fetch_data(q, nr) end
      ) do
        result = Query.query("Ale", "not_a_number")

        assert match?({:query_error, "Could not parse Integer from \"not_a_number\""}, result)
      end
    end

    test "Invalidation of 1+ hour old cache" do
      now = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
      past = now |> NaiveDateTime.add(-1, :hour)

      with_mock(TestBackend.QueryClient,
        fetch_data: fn q, nr -> QueryClientMock.fetch_data(q, nr) end
      ) do
        # Fetches from the API with time set to 1 hour in the past
        query_mocked_date(past)

        # Should not be cached due to the data "being" 1+ hour old
        {status, beers, has_next_page, cached} = Query.query("ale", "1")
        assert status == :ok
        assert length(beers) == 10
        assert has_next_page == true
        assert cached == false

        for beer <- beers do
          assert beer.updated_at == now
        end

        # Should be cached now
        {status, beers, has_next_page, cached} = Query.query("ale", "1")
        assert status == :ok
        assert length(beers) == 10
        assert has_next_page == true
        assert cached == true

        for beer <- beers do
          assert beer.updated_at == now
        end
      end
    end

    test "<1 hour old cache to not be invalidated" do
      now = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
      past = now |> NaiveDateTime.add(-1, :hour) |> NaiveDateTime.add(1, :second)

      with_mock(TestBackend.QueryClient,
        fetch_data: fn q, nr -> QueryClientMock.fetch_data(q, nr) end
      ) do
        # Fetches from the API with time set to <1 hour in the past
        query_mocked_date(past)

        # Should still be cached due to it "being" less than 1 hour old
        {status, beers, has_next_page, cached} = Query.query("ale", "1")
        assert status == :ok
        assert length(beers) == 10
        assert has_next_page == true
        assert cached == true

        for beer <- beers do
          assert beer.updated_at == past
        end
      end
    end
  end
end
