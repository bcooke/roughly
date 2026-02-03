---
name: liveview
description: Phoenix LiveView patterns for real-time UIs. Components, PubSub, streams, and hooks.
---

# LiveView Skill

Best practices for building real-time UIs with Phoenix LiveView.

## Component Patterns

### Functional Components

```elixir
defmodule RoughlyWeb.Components.QuestionCard do
  use Phoenix.Component

  attr :question, :map, required: true
  attr :class, :string, default: ""

  def question_card(assigns) do
    ~H"""
    <div class={["card bg-base-100 shadow-xl", @class]}>
      <div class="card-body">
        <h2 class="card-title"><%= @question.text %></h2>
        <div class="badge badge-outline"><%= @question.question_type %></div>
        <div class="card-actions justify-end">
          <.link navigate={~p"/questions/#{@question.uuid}"} class="btn btn-primary">
            View Results
          </.link>
        </div>
      </div>
    </div>
    """
  end
end
```

### Live Components

```elixir
defmodule RoughlyWeb.QuestionFormComponent do
  use RoughlyWeb, :live_component

  alias Roughly.Questions

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} phx-submit="save" phx-target={@myself}>
        <.input field={@form[:text]} type="text" label="Question" />
        <.input
          field={@form[:question_type]}
          type="select"
          label="Type"
          options={[{"Binary", :binary}, {"Multiple Choice", :multiple_choice}]}
        />
        <.button type="submit">Create Question</.button>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{question: question} = assigns, socket) do
    form = Questions.change_question(question) |> to_form()
    {:ok, assign(socket, assigns) |> assign(:form, form)}
  end

  @impl true
  def handle_event("save", %{"question" => params}, socket) do
    case Questions.create_question(params) do
      {:ok, question} ->
        send(self(), {:question_created, question})
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end
end
```

## LiveView Structure

```elixir
defmodule RoughlyWeb.QuestionLive.Index do
  use RoughlyWeb, :live_view

  alias Roughly.Questions

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Questions.subscribe()
    end

    {:ok,
     socket
     |> assign(:page_title, "Questions")
     |> stream(:questions, Questions.list_questions())}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    assign(socket, :question, nil)
  end

  defp apply_action(socket, :new, _params) do
    assign(socket, :question, %Question{})
  end

  @impl true
  def handle_info({:question_created, question}, socket) do
    {:noreply, stream_insert(socket, :questions, question, at: 0)}
  end

  @impl true
  def handle_info({:question_updated, question}, socket) do
    {:noreply, stream_insert(socket, :questions, question)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Questions
      <:actions>
        <.link patch={~p"/questions/new"}>
          <.button>New Question</.button>
        </.link>
      </:actions>
    </.header>

    <div id="questions" phx-update="stream" class="grid gap-4">
      <.question_card :for={{id, question} <- @streams.questions} id={id} question={question} />
    </div>

    <.modal :if={@live_action == :new} id="question-modal" show on_cancel={JS.patch(~p"/questions")}>
      <.live_component
        module={RoughlyWeb.QuestionFormComponent}
        id={:new}
        question={@question}
      />
    </.modal>
    """
  end
end
```

## PubSub for Real-time Updates

### Publishing Events

```elixir
defmodule Roughly.Questions do
  @topic "questions"

  def subscribe do
    Phoenix.PubSub.subscribe(Roughly.PubSub, @topic)
  end

  def broadcast({:ok, question}, event) do
    Phoenix.PubSub.broadcast(Roughly.PubSub, @topic, {event, question})
    {:ok, question}
  end

  def broadcast({:error, _} = error, _event), do: error

  def create_question(attrs) do
    %Question{}
    |> Question.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:question_created)
  end
end
```

### Subscribing in LiveView

```elixir
def mount(_params, _session, socket) do
  if connected?(socket) do
    Questions.subscribe()
  end
  {:ok, socket}
end

def handle_info({:question_created, question}, socket) do
  {:noreply, stream_insert(socket, :questions, question, at: 0)}
end
```

## Streams for Large Lists

```elixir
# Mount with stream
def mount(_params, _session, socket) do
  {:ok, stream(socket, :questions, Questions.list_questions())}
end

# Template with stream
<div id="questions" phx-update="stream">
  <div :for={{dom_id, question} <- @streams.questions} id={dom_id}>
    <%= question.text %>
  </div>
</div>

# Insert new item
stream_insert(socket, :questions, new_question, at: 0)

# Delete item
stream_delete(socket, :questions, question)

# Reset stream
stream(socket, :questions, new_list, reset: true)
```

## Form Handling

### Basic Form

```elixir
def mount(_params, _session, socket) do
  form = %Question{} |> Question.changeset(%{}) |> to_form()
  {:ok, assign(socket, :form, form)}
end

def handle_event("validate", %{"question" => params}, socket) do
  form =
    %Question{}
    |> Question.changeset(params)
    |> Map.put(:action, :validate)
    |> to_form()

  {:noreply, assign(socket, :form, form)}
end

def handle_event("save", %{"question" => params}, socket) do
  case Questions.create_question(params) do
    {:ok, question} ->
      {:noreply,
       socket
       |> put_flash(:info, "Question created!")
       |> push_navigate(to: ~p"/questions/#{question}")}

    {:error, changeset} ->
      {:noreply, assign(socket, :form, to_form(changeset))}
  end
end
```

### Template

```heex
<.form for={@form} phx-change="validate" phx-submit="save">
  <.input field={@form[:text]} type="text" label="Question" />
  <.input field={@form[:question_type]} type="select" label="Type" options={@types} />
  <.button type="submit" phx-disable-with="Saving...">Save</.button>
</.form>
```

## JavaScript Hooks

### Define Hook

```javascript
// assets/js/app.js
let Hooks = {}

Hooks.InfiniteScroll = {
  mounted() {
    this.observer = new IntersectionObserver(entries => {
      const entry = entries[0]
      if (entry.isIntersecting) {
        this.pushEvent("load-more", {})
      }
    })
    this.observer.observe(this.el)
  },
  destroyed() {
    this.observer.disconnect()
  }
}

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  params: {_csrf_token: csrfToken}
})
```

### Use in Template

```heex
<div id="infinite-scroll" phx-hook="InfiniteScroll"></div>
```

### Handle in LiveView

```elixir
def handle_event("load-more", _params, socket) do
  page = socket.assigns.page + 1
  questions = Questions.list_questions(page: page)

  {:noreply,
   socket
   |> assign(:page, page)
   |> stream(:questions, questions)}
end
```

## Navigation

### Push Navigate vs Patch

```elixir
# Full page navigation (new mount)
push_navigate(socket, to: ~p"/questions/#{question}")

# In-page navigation (handle_params only)
push_patch(socket, to: ~p"/questions?page=2")
```

### Links

```heex
<!-- Full navigation -->
<.link navigate={~p"/questions/#{question}"}>View</.link>

<!-- Patch navigation -->
<.link patch={~p"/questions?page=2"}>Page 2</.link>
```

## Flash Messages

```elixir
socket
|> put_flash(:info, "Success!")
|> put_flash(:error, "Something went wrong")
```

```heex
<.flash_group flash={@flash} />
```

## Best Practices

### Do
- Use streams for lists
- Subscribe to PubSub on mount
- Use `connected?(socket)` guard for subscriptions
- Validate on change, save on submit
- Use functional components for stateless UI

### Don't
- Store large data in assigns
- Make blocking calls in mount
- Forget to handle disconnects
- Use live components for simple UI
- Query database on every event

## Testing LiveView

```elixir
defmodule RoughlyWeb.QuestionLive.IndexTest do
  use RoughlyWeb.ConnCase

  import Phoenix.LiveViewTest

  test "lists questions", %{conn: conn} do
    question = insert(:question, text: "Test question")

    {:ok, view, _html} = live(conn, ~p"/questions")

    assert has_element?(view, "#question-#{question.uuid}")
    assert render(view) =~ "Test question"
  end

  test "creates new question", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/questions")

    view
    |> element("a", "New Question")
    |> render_click()

    assert_patch(view, ~p"/questions/new")

    view
    |> form("#question-form", question: %{text: "New question"})
    |> render_submit()

    assert_patch(view, ~p"/questions")
    assert render(view) =~ "New question"
  end
end
```

## Remember

- LiveView is for real-time, interactive UIs
- PubSub enables multi-user collaboration
- Streams are essential for performance
- Hooks bridge to JavaScript when needed
- Test behavior, not implementation
