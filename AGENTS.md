# Roughly contributor guidance

Roughly is an open collection of the world's percentages. Read `README.md`, `PROJECT_STATUS.md`, and `vault/README.md` for the current product and engineering context.

## Shared workflow

- This file is the canonical guidance for all coding tools. CLAUDE.md imports it.
- Keep product decisions, architecture, methodology, and contribution instructions public and impersonal. Keep personal notes, raw brain dumps, and unrelated private project context outside this repository.
- For documentation, read `vault/_meta/Documentation Guidelines.md`. Search before creating notes; use atomic concepts, meaningful links, topic maps, dated research, and decision records. Keep provisional observations distinct from settled guidance.
- Read the code before assuming a specification is implemented. Keep development fixtures isolated and documented in tooling; do not litter the product UI with fixture caveats or unrequested persuasive copy. Never publish invented responses as empirical results or imply an open poll is a representative sample.
- Use focused branches and ready PRs with relevant checks and a brief diff review. Use a small T/BUG/IMP record for meaningful work and a context file when there are findings worth retaining; avoid backfilling minor edits or mirroring issue state. Follow `vault/Project Workflow.md`. Do not publish or deploy without authorization.
- Follow test-driven development for domain behavior: demonstrate a failing test, implement, then refactor. Test externally visible outcomes.
- Use domain entry points and named query modules. Commands flow through Commanded; reads use Ecto projections. Start projectors after Roughly.App.
- Define one module per file. Preserve serialized event module names and payload compatibility when changing existing streams.
- Use Vue through LiveVue for interactive presentation, with Phoenix owning routes and server state. No PrimeVue. Review each new dependency for purpose and license; avoid adding libraries for simple UI.
- Public pages expose aggregates, never private answer histories. A reviewed participation policy, consent, and privacy behavior are required before enabling collection.
- Run `mix precommit` and the frontend production build before finishing application changes.

## Phoenix conventions

This is a web application written using the Phoenix web framework.

## Project guidelines

- Use `mix precommit` alias when you are done with all changes and fix any pending issues
- Use the already included and available `:req` (`Req`) library for HTTP requests, **avoid** `:httpoison`, `:tesla`, and `:httpc`. Req is included by default and is the preferred HTTP client for Phoenix apps

### Phoenix v1.8 guidelines

- **Always** begin your LiveView templates with `<Layouts.app flash={@flash} ...>` which wraps all inner content
- The `RoughlyWeb.Layouts` module is aliased in the `roughly_web.ex` file, so you can use it without needing to alias it again
- Phoenix v1.8 moved the `<.flash_group>` component to the `Layouts` module. You are **forbidden** from calling `<.flash_group>` outside of the `layouts.ex` module
- Out of the box, `core_components.ex` imports an `<.icon name="hero-x-mark" class="w-5 h-5"/>` component for hero icons. **Always** use the `<.icon>` component for icons
- **Always** use the imported `<.input>` component for form inputs from `core_components.ex` when available

### JS and CSS guidelines

- **Use Tailwind CSS classes and custom CSS rules** to create polished, responsive, and visually stunning interfaces
- Tailwindcss v4 **no longer needs a tailwind.config.js** and uses a new import syntax in `app.css`
- **Never** use `@apply` when writing raw css
- Out of the box **only the app.js and app.css bundles are supported**
- **Never write inline `<script>` tags within templates**

## Elixir guidelines

- Elixir lists **do not support index based access via the access syntax**

  **Never do this (invalid)**:
      mylist = ["blue", "green"]
      mylist[0]

  Instead, **always** use `Enum.at`, pattern matching, or `List` for index based list access

- Elixir variables are immutable, but can be rebound. For block expressions like `if`, `case`, `cond`, you *must* bind the result to a variable:

      # VALID: bind the result
      socket =
        if connected?(socket) do
          assign(socket, :val, val)
        else
          socket
        end

- **Never** nest multiple modules in the same file
- **Never** use map access syntax (`changeset[:field]`) on structs. Use `struct.field` or `Ecto.Changeset.get_field/2`
- Don't use `String.to_atom/1` on user input (memory leak risk)
- Predicate function names should end in `?`, not start with `is_`
- Use `Task.async_stream(collection, callback, timeout: :infinity)` for concurrent enumeration

## Mix guidelines

- Read the docs before using tasks: `mix help task_name`
- Debug test failures: `mix test test/my_test.exs` or `mix test --failed`
- `mix deps.clean --all` is **almost never needed**

## Phoenix guidelines

- Router `scope` blocks include an optional alias prefixed for all routes. Be mindful to avoid duplicate prefixes
- You **never** need to create your own `alias` for route definitions - the `scope` provides it
- `Phoenix.View` is no longer included with Phoenix, don't use it

## Ecto Guidelines

- **Always** preload associations if accessed in templates
- `Ecto.Schema` fields use `:string` type even for `:text` columns
- Use `Ecto.Changeset.get_field(changeset, :field)` to access changeset fields
- Fields set programmatically (like `user_id`) must not be in `cast` calls

## Phoenix HTML guidelines

- Phoenix templates **always** use `~H` or .html.heex files, **never** `~E`
- **Always** use `Phoenix.Component.form/1` and `to_form/2`, **never** `Phoenix.HTML.form_for`
- **Always** add unique DOM IDs to key elements for testing
- Elixir does NOT support `if/else if`. Use `cond` or `case` for multiple conditionals
- HEEx class attrs must use list `[...]` syntax for multiple/conditional classes:

      <a class={["px-2", @flag && "py-5"]}>Text</a>

- **Always** use `{...}` for interpolation in attributes, `<%= %>` only for block constructs in tag bodies
- HEEx comments: `<%!-- comment --%>`

## Phoenix LiveView guidelines

- **Never** use deprecated `live_redirect`/`live_patch`. Use `<.link navigate={}>` or `push_navigate`
- **Avoid LiveComponent's** unless specifically needed
- LiveViews should be named with `Live` suffix: `RoughlyWeb.QuestionLive`
- With `phx-hook`, you **must** also set `phx-update="ignore"` if the hook manages DOM
- **Never** write embedded `<script>` tags in HEEx

### LiveView streams

- **Always** use streams for collections to avoid memory issues
- Set `phx-update="stream"` on parent element with a DOM id
- Streams are *not* enumerable. To filter, refetch and re-stream with `reset: true`
- **Never** use deprecated `phx-update="append"` or `phx-update="prepend"`

### LiveView tests

- Use `Phoenix.LiveViewTest` and `LazyHTML` for assertions
- **Always** reference key element IDs in tests
- **Never** test against raw HTML - use `element/2`, `has_element/2`
- Test outcomes, not implementation details

### Form handling

- **Always** use `to_form/2` in LiveView and `<.input>` component in template
- **Never** access changesets directly in templates - use `@form[:field]`
- Always give forms explicit, unique DOM IDs
