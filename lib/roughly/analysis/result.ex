defmodule Roughly.Analysis.Result do
  @moduledoc "Public aggregate read contracts. No participant identifiers or private response history."
  @type answer :: %{
          id: Ecto.UUID.t(),
          label: String.t(),
          count: non_neg_integer(),
          percentage: float()
        }
  @type t :: %{
          uuid: Ecto.UUID.t(),
          slug: String.t(),
          text: String.t(),
          language: String.t(),
          question_type: Roughly.Questions.Instrument.kind(),
          category: String.t() | nil,
          total: non_neg_integer(),
          answers: [answer()]
        }
  @type page :: %{
          entries: [t()],
          total: non_neg_integer(),
          page: pos_integer(),
          total_pages: pos_integer()
        }
end
