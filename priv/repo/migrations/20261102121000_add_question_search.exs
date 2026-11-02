defmodule Roughly.Repo.Migrations.AddQuestionSearch do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS pg_trgm"

    alter table(:questions) do
      add :search_document, :text, null: false, default: ""
    end

    execute """
    UPDATE questions q SET search_document = concat_ws(' ', q.text, q.category,
      (SELECT string_agg(option->>'label', ' ') FROM unnest(q.options) AS choice(option)))
    """

    execute "CREATE INDEX questions_search_trgm ON questions USING gin (search_document gin_trgm_ops)"

    execute "CREATE INDEX questions_search_words ON questions USING gin (to_tsvector('english', search_document))"
  end

  def down do
    drop index(:questions, [], name: :questions_search_trgm)
    drop index(:questions, [], name: :questions_search_words)
    alter table(:questions), do: remove(:search_document)
  end
end
