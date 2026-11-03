defmodule RoughlyWeb.PageMetadata do
  @moduledoc "Server-rendered discovery metadata; preview fixtures are not indexable."
  import Plug.Conn
  alias Roughly.Analysis.AnswerLinks, as: AnswerRoutes
  @spec init(keyword()) :: keyword()
  def init(opts), do: opts
  @spec call(Plug.Conn.t(), keyword()) :: Plug.Conn.t()
  def call(conn, _) do
    conn = fetch_query_params(conn)

    case conn.path_params do
      %{"slug" => slug} ->
        question = Roughly.Questions.get_question(slug)
        answer_slug = conn.path_params["answer_slug"]

        if question && (is_nil(answer_slug) || AnswerRoutes.find(question, answer_slug)) do
          assign(
            conn,
            :page_metadata,
            for_question(question, answer_slug, meaningful?(conn.query_params))
          )
        else
          conn
          |> put_status(:not_found)
          |> assign(:page_metadata, default(conn.request_path, "Question not found"))
        end

      _ ->
        page = RoughlyWeb.GuidePages.for_path(conn.request_path)

        assign(
          conn,
          :page_metadata,
          if(page, do: for_guide(page), else: default(conn.request_path))
        )
    end
  end

  @spec for_guide(map()) :: map()
  def for_guide(page), do: metadata(page.title, page.description, page.path, false)

  @spec for_question(Roughly.Analysis.Result.t(), String.t() | nil, boolean()) :: map()
  def for_question(question, answer_slug \\ nil, filtered? \\ false) do
    answer = AnswerRoutes.find(question, answer_slug)
    title = if answer, do: "#{answer.label} · #{question.text}", else: question.text

    description =
      if filtered?,
        do: "Explore recorded responses to: #{question.text}",
        else: summary(question, answer)

    metadata(title, description, AnswerRoutes.path(question, answer_slug), filtered?)
  end

  @spec summary(map(), map() | nil) :: String.t()
  def summary(question, focus \\ nil) do
    cond do
      Map.get(question, :suppressed, false) ->
        "There are fewer than 10 eligible responses in this group."

      question.total == 0 ->
        "No responses to this question yet."

      true ->
        answer = focus || Enum.max_by(question.answers, & &1.count)

        "#{answer.percentage}% selected “#{answer.label}” — #{answer.count} of #{question.total} responses."
    end
  end

  @spec default(String.t(), String.t()) :: map()
  def default(path \\ "/", title \\ "The world’s percentages.") do
    metadata(
      title,
      "Explore recorded answers to questions about people’s experiences, habits, and preferences.",
      path,
      path == "/search"
    )
  end

  @spec meaningful?(map()) :: boolean()
  def meaningful?(params),
    do: Enum.any?(~w(population option as_of compare), &Map.has_key?(params, &1))

  defp metadata(title, description, path, filtered?) do
    public? = Application.get_env(:roughly, :public_indexing, false)

    %{
      title: title,
      description: description,
      canonical: RoughlyWeb.Endpoint.url() <> path,
      robots: if(public? && !filtered?, do: "index,follow", else: "noindex,follow")
    }
  end
end
