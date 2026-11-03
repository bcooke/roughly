defmodule RoughlyWeb.QuestionLive do
  use RoughlyWeb, :live_view
  import RoughlyWeb.Format, only: [number: 1]
  alias Roughly.{Questions, Analysis}
  alias RoughlyWeb.{ExplorationState, PageMetadata}
  alias Roughly.Analysis.AnswerLinks, as: AnswerRoutes

  @colors ["#326959", "#d6a758", "#7b8eaf", "#ba7c75", "#8b9b62", "#a28bb5"]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream_configure(:related, dom_id: &"related-#{&1.slug}")
     |> stream_configure(:answers, dom_id: &"answer-#{&1.index}")
     |> stream_configure(:columns, dom_id: &"scale-column-#{&1.index}")
     |> stream_configure(:table, dom_id: &"table-answer-#{&1.index}")
     |> stream_configure(:trend_rows, dom_id: &"trend-row-#{&1.key}")
     |> stream_configure(:groups, dom_id: &"comparison-group-#{&1.id}")
     |> stream_configure(:comparison_matches, dom_id: &"compare-match-#{&1.uuid}")
     |> stream_configure(:featured, dom_id: &"compare-featured-#{&1.uuid}")
     |> stream(:trend_rows, [])
     |> stream(:groups, [])
     |> stream(:comparison_matches, [])
     |> stream(:featured, [])
     |> stream(:columns, [])
     |> stream(:table, [])
     |> stream(:related, [])
     |> stream(:answers, [])}
  end

  @impl true
  def handle_params(%{"slug" => slug} = params, _uri, socket) do
    case load_question(slug, params["answer_slug"]) do
      {nil, _} ->
        {:noreply,
         assign(socket,
           question: nil,
           page_title: "Question not found",
           page_metadata: PageMetadata.default("/questions/#{slug}", "Question not found")
         )}

      {question, focus} ->
        render_question(socket, question, focus, params)
    end
  end

  defp render_question(socket, question, focus, params) do
    state = ExplorationState.parse(params)

    opts = [
      cutoff: state.cutoff,
      basis: state.basis,
      population: state.population,
      axis: state.axis,
      months: state.months
    ]

    result = selected_result(question, state, opts)
    visible = visible_result(result) |> Map.put(:answer_slug, option_slug(focus))
    focused = focused_result(result, focus)
    answers = chart_answers(visible)
    measure = measure(question, focus, params)
    featured = Analysis.featured_comparisons() |> Enum.reject(&(&1.uuid == question.uuid))
    source = state.comparison || List.first(featured)
    comparison = comparison(question, source, opts)
    groups = comparison_groups(comparison, measure)
    points = Analysis.trend(question, opts)
    analysis_params = analysis_parameters(state, params, measure)
    view = if params["view"] == "table", do: "table", else: "chart"
    metric = if params["metric"] == "count", do: "count", else: "percentage"

    metadata =
      PageMetadata.for_question(
        question,
        option_slug(focus),
        PageMetadata.meaningful?(analysis_params)
      )

    {:noreply,
     socket
     |> assign(
       question: visible,
       page_title: metadata.title,
       page_metadata: metadata,
       view: view,
       metric: metric,
       chart: chart_type(visible),
       state: state,
       analysis_params: analysis_params,
       route_params: Map.merge(analysis_params, %{"view" => view, "metric" => metric}),
       focus: focus,
       focus_label: option_label(focus),
       suppressed: result.suppressed,
       option_count: length(question.answers),
       answer_summary: PageMetadata.summary(result, focused),
       trend_points: points,
       trend_has_data: Enum.any?(points, &has_data?/1),
       trend_answers: chart_answers(question),
       comparison: comparison,
       measure: measure,
       compare_form: to_form(%{"query" => ""}),
       analysis_form: analysis_form(state)
     )
     |> stream(:columns, answers, reset: true)
     |> stream(:table, answers, reset: true)
     |> stream(:answers, answers, reset: true)
     |> stream(:trend_rows, points, reset: true)
     |> stream(:groups, groups, reset: true)
     |> stream(:featured, featured, reset: true)
     |> stream(:related, Questions.related_questions(question), reset: true)}
  end

  defp load_question(slug, answer_slug) do
    question = Questions.get_question(slug)
    focus = if question, do: AnswerRoutes.find(question, answer_slug)
    if answer_slug && is_nil(focus), do: {nil, nil}, else: {question, focus}
  end

  defp selected_result(question, %{as_of: nil, population: nil}, _),
    do: Map.put(question, :suppressed, false)

  defp selected_result(question, _, opts), do: Analysis.public_result(question, opts)
  defp visible_result(%{suppressed: true} = result), do: %{result | total: 0, answers: []}
  defp visible_result(result), do: result
  defp focused_result(_, nil), do: nil
  defp focused_result(result, focus), do: Enum.find(result.answers, &(&1.id == focus.id))
  defp option_slug(nil), do: nil
  defp option_slug(option), do: option.slug
  defp option_label(nil), do: nil
  defp option_label(option), do: option.label

  defp measure(question, focus, params),
    do:
      Enum.find(question.answers, &(&1.id == params["measure"])) || focus ||
        Enum.max_by(question.answers, & &1.count)

  defp comparison(_, nil, _), do: nil

  defp comparison(question, source, opts),
    do: Analysis.compare(question, source, Keyword.delete(opts, :population))

  defp comparison_groups(nil, _), do: []

  defp comparison_groups(comparison, measure),
    do:
      Enum.map(
        comparison.groups,
        &Map.put(&1, :value, Enum.find(&1.answers, fn answer -> answer.id == measure.id end))
      )

  defp analysis_parameters(state, params, measure) do
    parameters = ExplorationState.parameters(state)
    if params["measure"], do: Map.put(parameters, "measure", measure.id), else: parameters
  end

  defp has_data?(%{total: nil}), do: false
  defp has_data?(%{total: total}), do: total > 0

  defp analysis_form(state) do
    to_form(%{
      "as_of" => if(state.as_of, do: Date.to_iso8601(state.as_of), else: ""),
      "basis" => to_string(state.basis),
      "axis" => to_string(state.axis),
      "months" => to_string(state.months)
    })
  end

  @impl true
  def handle_event("explore", params, socket) do
    updates = Map.take(params, ~w(as_of basis axis months))

    {:noreply,
     push_patch(socket,
       to: explore_path(socket.assigns.question, socket.assigns.route_params, updates)
     )}
  end

  def handle_event("comparison_search", %{"query" => query}, socket) when is_binary(query) do
    matches = if String.trim(query) == "", do: [], else: Roughly.Search.suggest(query).questions

    {:noreply,
     stream(
       socket,
       :comparison_matches,
       Enum.reject(matches, &(&1.uuid == socket.assigns.question.uuid)),
       reset: true
     )}
  end

  def handle_event("comparison_measure", %{"measure" => measure}, socket) do
    {:noreply,
     push_patch(socket,
       to:
         explore_path(socket.assigns.question, socket.assigns.route_params, %{
           "measure" => measure
         })
     )}
  end

  defp section_navigation(assigns) do
    ~H"""
    <nav id={@id} class={@class} aria-label="Explore this question">
      <a href="#results">Breakdown</a><a href="#trends">Over time</a><a href="#population-comparison">Compare populations</a>
    </nav>
    """
  end

  defp exploration_sections(assigns) do
    ~H"""
    <div class="analysis-grid">
      <section id="trends" class="evidence-section" aria-labelledby="trends-title">
        <div class="evidence-section-heading">
          <div>
            <h2 id="trends-title">
              Answers over time
            </h2>
          </div><div class="trend-heading-tools">
            <span class="evidence-badge">Cumulative</span><nav
              class="trend-unit-switch"
              aria-label="Trend values"
            >
              <.link
                id="trend-unit-percentage"
                patch={explore_path(@question, @route_params, %{"metric" => "percentage"})}
                class={[@metric == "percentage" && "selected"]}
              >%</.link><.link
                id="trend-unit-count"
                patch={explore_path(@question, @route_params, %{"metric" => "count"})}
                class={[@metric == "count" && "selected"]}
              >Count</.link>
            </nav>
          </div>
        </div>
        <.form
          for={@analysis_form}
          id="exploration-controls"
          phx-change="explore"
          class="exploration-controls"
        >
          <div class="evidence-select">
            <.input
              field={@analysis_form[:axis]}
              id="trend-axis"
              type="select"
              label="Horizontal axis"
              options={[{"Time", "date"}, {"Number of responses", "responses"}]}
            /><.icon name="hero-chevron-down" class="size-4 evidence-select-arrow" />
          </div>
          <div class="evidence-select">
            <.input
              field={@analysis_form[:months]}
              id="trend-range"
              disabled={@state.axis == :responses}
              type="select"
              label="Range"
              options={[
                {"3 months", "3"},
                {"6 months", "6"},
                {"12 months", "12"},
                {"24 months", "24"}
              ]}
            /><.icon name="hero-chevron-down" class="size-4 evidence-select-arrow" />
          </div>
          <details class="timeline-date-options">
            <summary>Date options <.icon name="hero-chevron-down" class="size-3" /></summary><div class="timeline-date-fields">
              <div class="evidence-select">
                <.input
                  field={@analysis_form[:basis]}
                  id="trend-basis"
                  disabled={@state.axis == :responses}
                  type="select"
                  label="Date basis"
                  options={[{"Answer date", "answered"}, {"Receipt date", "recorded"}]}
                /><.icon name="hero-chevron-down" class="size-4 evidence-select-arrow" />
              </div>
              <.input
                field={@analysis_form[:as_of]}
                id="analysis-as-of"
                type="date"
                label="Through date"
                max={Date.to_iso8601(Date.utc_today())}
              />
            </div>
          </details>
        </.form>
        <p class="evidence-caption">
          {if @state.axis == :responses,
            do:
              "Distribution in receipt order, by total question responses. Selected populations use their own denominator.",
            else: "Month-end distributions through the selected date."} {if @state.basis == :answered &&
                                                                              @state.axis !=
                                                                                :responses,
                                                                            do:
                                                                              "Supplied answer dates are used where available."}
        </p>
        <.vue
          :if={@trend_has_data}
          id="response-trend-chart"
          v-component="TrendChart"
          v-socket={@socket}
          v-ssr={false}
          points={@trend_points}
          answers={@trend_answers}
          metric={@metric}
          focus_id={@focus && @focus.id}
          axis={to_string(@state.axis)}
          scoped={not is_nil(@state.population)}
        />
        <p :if={!@trend_has_data} id="trend-empty" class="evidence-empty">
          No eligible dated responses in this range.
        </p>
        <details class="trend-data-table">
          <summary>View the values <.icon name="hero-table-cells" class="size-4" /></summary><div class="evidence-table-scroll">
            <table>
              <caption class="sr-only">Cumulative response distributions at each checkpoint</caption><thead>
                <tr>
                  <th scope="col">Checkpoint</th><th scope="col">Responses</th><th scope="col">
                    Distribution
                  </th>
                </tr>
              </thead><tbody id="trend-data-rows" phx-update="stream">
                <tr :for={{id, point} <- @streams.trend_rows} id={id}>
                  <th scope="row">{point.label}</th><td>
                    {if is_nil(point.total), do: "—", else: number(point.total)}
                  </td><td>{point_breakdown(point)}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </details>
      </section>
      <section id="population-comparison" class="evidence-section" aria-labelledby="comparison-title">
        <div class="evidence-section-heading">
          <div>
            <h2 id="comparison-title">
              Compare populations
            </h2>
          </div><.icon name="hero-user-group" class="size-5" />
        </div>
        <div id="comparison-featured" phx-update="stream" class="comparison-featured">
          <.link
            :for={{id, source} <- @streams.featured}
            id={id}
            patch={explore_path(@question, @route_params, %{"compare" => source.slug})}
            class={[@comparison && @comparison.source.uuid == source.uuid && "selected"]}
          >{dimension_label(source)}</.link>
        </div>
        <details class="comparison-question-picker">
          <summary>
            Choose another question <.icon name="hero-magnifying-glass" class="size-3" />
          </summary>

          <.form
            for={@compare_form}
            id="comparison-search"
            phx-change="comparison_search"
            phx-submit="comparison_search"
            class="comparison-search"
          >
            <.icon name="hero-magnifying-glass" class="size-4" /><.input
              field={@compare_form[:query]}
              id="comparison-query"
              placeholder="Or find another question to compare…"
              aria-label="Find a question to compare"
              phx-debounce="250"
              maxlength="200"
              autocomplete="off"
            />
          </.form>
          <div id="comparison-search-matches" phx-update="stream" class="comparison-search-matches">
            <.link
              :for={{id, source} <- @streams.comparison_matches}
              id={id}
              patch={explore_path(@question, @route_params, %{"compare" => source.slug})}
            >{source.text}<.icon name="hero-arrow-right" class="size-4" /></.link>
          </div>
        </details>
        <div :if={@comparison} class="comparison-body">
          <p :if={@state.population} class="evidence-caption">
            Comparisons below use all respondents to this question.
          </p>
          <div class="comparison-context">
            <span>Grouped by answers to</span><.link navigate={
              ~p"/questions/#{@comparison.source.slug}"
            }>{@comparison.source.text} <.icon name="hero-arrow-up-right" class="size-3" /></.link>
          </div>
          <.form
            for={to_form(%{"measure" => @measure.id})}
            id="comparison-measure-form"
            phx-change="comparison_measure"
            class="comparison-measure"
          >
            <div class="evidence-select">
              <.input
                name="measure"
                value={@measure.id}
                id="comparison-measure"
                type="select"
                label="Show share selecting"
                options={Enum.map(@trend_answers, &{&1.label, &1.id})}
              /><.icon name="hero-chevron-down" class="size-4 evidence-select-arrow" />
            </div>
          </.form>
          <div id="comparison-groups" phx-update="stream" class="comparison-groups">
            <div :for={{id, group} <- @streams.groups} id={id} class="comparison-group">
              <div class="comparison-group-heading">
                <strong>{group.label}</strong><span
                  :if={group.suppressed}
                  class="comparison-suppressed"
                >Fewer than 10 eligible responses</span><span :if={!group.suppressed}><strong>{group.value.percentage}%</strong><small>{number(
                  group.value.count
                )} of {number(group.total)} responses</small></span>
              </div><div :if={!group.suppressed} class="comparison-track">
                <div style={"width: #{group.value.percentage}%"}></div>
              </div><.link
                :if={!group.suppressed}
                patch={
                  explore_path(@question, @route_params, %{
                    "population" => @comparison.source.slug,
                    "option" => group.id
                  })
                }
              ><span>Explore this population</span> <.icon name="hero-arrow-right" class="size-3" /></.link>
            </div>
          </div>
          <p id="comparison-denominator" class="evidence-caption">
            {number(@comparison.eligible)} respondents answered both questions; {number(
              @comparison.missing
            )} have no qualifying answer. Groups use their own eligible respondent denominator and may overlap.
          </p>
        </div>
        <p :if={!@comparison} class="evidence-empty">
          Choose a question to compare its answer-defined populations.
        </p>
      </section>
    </div>
    """
  end

  defp point_breakdown(%{total: nil}), do: "Small group — distribution withheld"
  defp point_breakdown(%{total: 0}), do: "No responses"

  defp point_breakdown(point),
    do: Enum.map_join(point.answers, " · ", &"#{&1.label}: #{&1.percentage}% (#{&1.count})")

  defp chart_type(nil), do: "bars"
  defp chart_type(%{question_type: :ordered_scale}), do: "columns"
  defp chart_type(%{question_type: :multiple_select}), do: "bars"
  defp chart_type(_), do: "bars"

  defp chart_answers(question) do
    {answers, _} =
      question.answers
      |> Enum.with_index()
      |> Enum.map_reduce(0, fn {answer, index}, offset ->
        share = if question.total > 0, do: answer.count / question.total * 100, else: 0

        route = Enum.find(AnswerRoutes.entries(question), &(&1.id == answer.id))

        {Map.merge(answer, %{
           answer_slug: route.slug,
           index: index,
           color: Enum.at(@colors, rem(index, length(@colors))),
           share: share,
           offset: -offset
         }), offset + share}
      end)

    answers
  end

  defp answer_path(question, slug, params),
    do: explore_path(Map.put(question, :answer_slug, slug), params, %{})

  defp result_path(question, view, metric, params) do
    explore_path(question, params, %{"view" => view, "metric" => metric})
  end

  defp explore_path(question, params, updates) do
    query =
      Map.merge(params, updates)
      |> Enum.reject(fn {key, value} ->
        is_nil(value) || value == "" ||
          {key, value} in [{"view", "chart"}, {"metric", "percentage"}]
      end)
      |> Map.new()

    path = AnswerRoutes.path(question, question[:answer_slug])
    if query == %{}, do: path, else: path <> "?" <> URI.encode_query(query)
  end

  defp dimension_label(question) do
    case question.slug do
      "which-age-group-are-you-in" -> "Age group"
      "how-do-you-describe-your-gender" -> "Gender"
      "which-region-do-you-currently-live-in" -> "Region"
      _ -> question.text
    end
  end

  defp topic_path(nil), do: ~p"/"
  defp topic_path(topic), do: ~p"/?#{%{topic: topic}}"

  defp format_name(kind),
    do:
      %{
        binary: "Two options",
        single_choice: "Single choice",
        multiple_select: "Multiple selections",
        ordered_scale: "Ordered scale"
      }[kind]

  defp value(answer, "count"), do: number(answer.count)
  defp value(answer, _), do: "#{answer.percentage}%"
end
