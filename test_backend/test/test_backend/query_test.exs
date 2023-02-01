defmodule TestBackend.QueryTest do
  use ExUnit.Case, async: false
  use Plug.Test
  use TestBackend.RepoCase

  import Mock

  require Logger

  alias TestBackend.QueryClientMock
  alias TestBackend.Query

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
  end
end
