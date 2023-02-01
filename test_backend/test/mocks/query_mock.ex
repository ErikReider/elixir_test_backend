defmodule TestBackend.QueryClientMock do
  def fetch_data(query, page_nr) do
    {:ok, response(query, page_nr)}
  end

  defp response(query, page_nr) do
    {body, status} =
      case query do
        "ale" ->
          {:ok, file} = File.read("./test/mock_data/beers_#{query}-#{page_nr}.json")
          {file, 200}

        _ ->
          {"", 404}
      end

    %HTTPoison.Response{
      body: body,
      headers: [
        {"Content-Type", "application/json"},
        {"Content-Length", "#{String.length(body)}"}
      ],
      status_code: status
    }
  end
end
