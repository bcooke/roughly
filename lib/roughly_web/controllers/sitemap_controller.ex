defmodule RoughlyWeb.SitemapController do
  use RoughlyWeb, :controller
  alias Roughly.Analysis.Queries.CrawlPages

  def index(conn, _) do
    pages = if public?(), do: ceil(CrawlPages.count() / 1_000), else: 0
    paths = if pages == 0, do: [], else: Enum.map(1..pages, &"/sitemaps/questions/#{&1}.xml")

    if paths == [],
      do: send_resp(conn, 404, "Sitemap not published"),
      else: xml(conn, "sitemapindex", paths, "sitemap")
  end

  def questions(conn, %{"page" => value}) do
    with true <- public?(),
         [_, digits] <- Regex.run(~r/^([1-9][0-9]{0,5})\.xml$/, value),
         page = String.to_integer(digits),
         true <- page <= ceil(CrawlPages.count() / 1_000) do
      xml(conn, "urlset", CrawlPages.call(page), "url")
    else
      _ -> send_resp(conn, 404, "Sitemap not found")
    end
  end

  defp public?, do: Application.get_env(:roughly, :public_indexing, false)

  defp xml(conn, root, paths, tag) do
    urls =
      Enum.map_join(paths, "", fn path ->
        url =
          (RoughlyWeb.Endpoint.url() <> path)
          |> Phoenix.HTML.html_escape()
          |> Phoenix.HTML.safe_to_string()

        "<#{tag}><loc>#{url}</loc></#{tag}>"
      end)

    conn
    |> put_resp_content_type("application/xml")
    |> send_resp(
      200,
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?><#{root} xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">#{urls}</#{root}>"
    )
  end
end
