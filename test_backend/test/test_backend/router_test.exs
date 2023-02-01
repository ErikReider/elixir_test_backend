defmodule TestBackend.RouterTest do
  use ExUnit.Case, async: false
  use Plug.Test
  use TestBackend.RepoCase

  import Mock

  require Logger

  alias TestBackend.QueryClientMock

  @opts TestBackend.Router.init([])

  @valid_search_query "Ale"

  @doc """
  Connect to the api but return with mock data
  """
  def connect_to_api(query, page_nr) do
    with_mock(TestBackend.QueryClient,
      fetch_data: fn q, nr -> QueryClientMock.fetch_data(q, nr) end
    ) do
      conn(:get, "/", %{query: query, page_nr: page_nr})
      |> TestBackend.Router.call(@opts)
    end
  end

  describe "Test parameters" do
    test "it returns 400 when query is empty" do
      conn = connect_to_api("", 1)

      assert conn.status == 400
      assert conn.resp_body == "Query cannot be empty"
    end

    test "it returns 400 when page_nr 0" do
      conn = connect_to_api(@valid_search_query, 0)

      assert conn.status == 400
      assert conn.resp_body == "Page number must start with 0"
    end

    test "it returns 400 when page_nr cannot be parsed" do
      conn = connect_to_api(@valid_search_query, "Not a number")

      assert conn.status == 400
      assert conn.resp_body == "Could not parse Integer from \"Not a number\""
    end
  end

  describe "Test caching" do
    test "it returns 200 and caches data" do
      # First load of page 1
      conn = connect_to_api(@valid_search_query, 1)

      assert conn.status == 200

      {:ok, json} = Jason.decode(conn.resp_body)

      assert length(json["beers"]) > 0
      assert json["cached"] == false
      assert json["has_next_page"] == true

      # Reload and data should be cached
      conn = connect_to_api(@valid_search_query, 1)

      assert conn.status == 200

      {:ok, json} = Jason.decode(conn.resp_body)

      assert length(json["beers"]) > 0
      assert json["cached"] == true
      assert json["has_next_page"] == true
    end

    test "it returns 200 and uses the cached data for page 2" do
      # First load of page 2
      conn = connect_to_api(@valid_search_query, 1)

      assert conn.status == 200

      {:ok, json} = Jason.decode(conn.resp_body)

      assert length(json["beers"]) > 0
      assert json["cached"] == false
      assert json["has_next_page"] == true

      # Reload and data should be cached
      conn = connect_to_api(@valid_search_query, 2)

      assert conn.status == 200

      {:ok, json} = Jason.decode(conn.resp_body)

      assert length(json["beers"]) > 0
      assert json["cached"] == true
      assert json["has_next_page"] == true
    end
  end

  test "it returns 200 with an empty array for page 1000" do
    conn = connect_to_api(@valid_search_query, 1000)

    assert conn.status == 200

    {:ok, json} = Jason.decode(conn.resp_body)

    assert length(json["beers"]) == 0
    assert json["has_next_page"] == false
  end

  test "it returns 404 when no route matches" do
    conn = conn(:get, "/invalid") |> TestBackend.Router.call(@opts)

    assert conn.status == 404
  end
end
