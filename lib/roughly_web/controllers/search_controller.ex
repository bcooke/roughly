defmodule RoughlyWeb.SearchController do
  use RoughlyWeb, :controller

  def suggest(conn, params) do
    case Map.get(params, "q", "") do
      query when is_binary(query) ->
        conn
        |> put_resp_header("cache-control", "no-store")
        |> json(Roughly.Search.suggest(query))

      _ ->
        conn |> put_status(:bad_request) |> json(%{error: "Search query must be text"})
    end
  end
end
