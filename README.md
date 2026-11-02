# Roughly

An open collection of the world's percentages. Explore questions about human preferences, behavior, and attitudes, with transparent counts and methodology.

Roughly is intended to be free, open source, and community supported. See the [product vision](vault/Product%20Vision.md).

## Current application

The local application browses persisted questions and aggregate responses, with topic filters, global search, pagination, related questions, an About page, and readable result URLs. Search includes live question/topic suggestions, Command/Ctrl K, keyboard navigation, session recents, typo tolerance, and a full results page with format filters. Development setup seeds **209 questions across 18 topics, 360 invented participants, and 33,177 invented responses**. These are local fixtures, not researched polling data. Question pages include dated trends, answer-defined population comparisons, and readable answer-specific URLs. Authentication, real voting, and representative population estimates are not available.

## Run locally

Install [mise](https://mise.jdx.dev/) and Docker, then:

```sh
mise install
mise exec -- docker compose up -d db
mise exec -- mix setup
mise exec -- mix phx.server
```

Open **http://localhost:4070**. Phoenix starts the Vite development watcher on port 5293. The dedicated PostgreSQL container uses port 5435 and its own Docker volume. It does not share databases with other applications. Development database credentials are local defaults; `PGHOST`, `PGPORT`, `PGUSER`, and `PGPASSWORD` can override them.

Without mise, use the Elixir, Erlang, and Node versions recorded in `mise.toml`. A compatible PostgreSQL installation can replace Docker.

`mix setup` fetches Elixir dependencies, creates and migrates the read database, initializes EventStore, installs locked npm dependencies, and builds assets. It does not drop existing databases. In development it seeds invented participants, questions, and responses through Commanded. The UI reads their Ecto projections. Seed code lives in `dev/` and is excluded from production compilation.

## Development fixtures

```sh
mise exec -- mix dev.seed
```

The versioned catalog is `dev/roughly/dev/questions.json`. It contains curated prompts, answer choices, and invented weights. Stable UUIDs make seeding deterministic and resumable; reruns preserve counts rather than adding votes. Responses carry development-source event metadata. No real user data, external LLM service, Faker package, or credentials are needed.

Only development config enables seed execution. Never use the seeded development database as public polling data. To reset local data intentionally, `mix ecto.reset` resets **both** Ecto and EventStore and reseeds the development database. Stop the server first. This deletes local data; it is not required for an ordinary seed rerun. Reset after changing fixture meanings, weights, or a projection shape that requires replay: stable IDs deliberately do not rewrite their recorded history. The fixture generator does not delete existing data.

## Verify changes

```sh
mise exec -- mix precommit
mise exec -- mix assets.build
```

The checks compile with warnings as errors, run Credo, check Elixir formatting, validate the vault graph, and run backend and frontend request-state tests. The frontend build checks Vue/TypeScript and builds Vite assets. GitHub Actions runs these checks against PostgreSQL.

## Architecture

- Phoenix 1.8 and LiveView own routes and server state.
- Vue 3 through LiveVue handles client interactions; Tailwind 4 and custom CSS style the interface.
- Commanded aggregates emit immutable events into PostgreSQL EventStore. Supervised projectors maintain Ecto read models.
- Trusted writes use the actor-aware Dispatch seam, domain command validation, and capability/ownership admission. Public authentication and voting remain disabled.
- Questions are read through named query modules and the Questions facade. Aggregate results exclude withdrawn responses and do not expose participant identities.

See [system architecture](vault/System%20Architecture.md), [documentation](vault/README.md), and [project status](PROJECT_STATUS.md).

## Contribute

Read [CONTRIBUTING.md](CONTRIBUTING.md) and [AGENTS.md](AGENTS.md). Shared instructions work with any coding assistant. No proprietary AI tool, subscription, or slash-command system is required.

Dependencies should have a clear purpose and compatible open-source licenses. No PrimeVue or commercial component suite is required. Before real response collection, decide the participation model, complete the collection and study-policy boundaries in [ADR-003](vault/decisions/ADR-003-domain-admission-and-context-boundaries.md), and implement the privacy and abuse safeguards in [Methodology](vault/Polling%20Methodology.md).

## Deployment

This repository is a development preview. Production needs separate `DATABASE_URL` and `EVENTSTORE_DATABASE_URL`, `SECRET_KEY_BASE`, `PHX_HOST`, built assets, and database/EventStore initialization. It has not been deployed by this refresh.

## License

MIT. See [LICENSE](LICENSE).

## Search discovery

Question and answer views render their summary, counts, and Dataset microdata in initial HTML. Canonical metadata and bounded sitemap shards support later publication. Indexing remains disabled by default; only production with `ROUGHLY_PUBLIC_INDEXING=true` enables it. Replace fictional data and establish the publication policy before enabling that flag. See [Answer Discovery](vault/Answer%20Discovery.md).
