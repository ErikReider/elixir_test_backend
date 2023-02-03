defmodule TestBackend.Router do
  use Plug.Router
  use Plug.ErrorHandler

  alias TestBackend.Query

  plug(Plug.Logger)

  plug(CORSPlug, methods: ["GET"])

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:match)
  plug(:dispatch)

  get "/" do
    with %{"query" => query, "page_nr" => page_nr}
         when is_bitstring(query) and is_bitstring(page_nr) <- conn.params,
         {:ok, beers, has_next_page, cached} <- Query.query(query, page_nr) do
      body = Jason.encode!(%{cached: cached, has_next_page: has_next_page, beers: beers})
      send_resp(conn |> put_resp_content_type("application/json"), 200, body)
    else
      {:error, error} -> send_resp(conn, 500, inspect(error))
      {:query_error, error} -> send_resp(conn, 400, error)
      _ -> send_resp(conn, 400, "Missing \"query\" and \"page_nr\"")
    end
  end

  match _ do
    send_resp(conn, 404, "Nothing here...")
  end

  @impl Plug.ErrorHandler
  def handle_errors(conn, %{kind: kind, reason: reason, stack: stack}) do
    IO.inspect(kind, label: :kind)
    IO.inspect(reason, label: :reason)
    IO.inspect(stack, label: :stack)

    body = "Something went wrong...\n"

    send_resp(
      conn,
      conn.status,
      case "#{Mix.env()}" do
        "dev" ->
          body = body <> "Kind: #{inspect(kind)}\n\n"
          body = body <> "Reason: #{inspect(reason)}\n\n"
          body = body <> "Stack: #{inspect(stack)}\n\n"
          body

        _ ->
          body
      end
    )
  end
end
