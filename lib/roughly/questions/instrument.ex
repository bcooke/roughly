defmodule Roughly.Questions.Instrument do
  @moduledoc "Immutable question definition and answer semantics, independent of chart presentation."
  alias Roughly.Questions.Option
  @type kind :: :binary | :single_choice | :multiple_select | :ordered_scale
  @kinds [:binary, :single_choice, :multiple_select, :ordered_scale]

  @spec valid_options?(term(), term()) :: boolean()
  def valid_options?(values, kind) when is_list(values) do
    kind in @kinds and length(values) in 2..20 and (kind != :binary or length(values) == 2) and
      Enum.all?(values, &Option.valid?/1) and unique_options?(values)
  end

  def valid_options?(_, _), do: false

  defp unique_options?(values) do
    length(Enum.uniq_by(values, & &1.id)) == length(values) and
      length(Enum.uniq_by(values, &String.trim(&1.label))) == length(values)
  end

  @spec admit(Roughly.Questions.Question.t(), [Ecto.UUID.t()], Roughly.Participation.Context.t()) ::
          :ok | {:error, atom()}
  def admit(%{uuid: nil}, _, _), do: {:error, :question_not_found}
  def admit(%{status: :closed}, _, _), do: {:error, :question_closed}

  def admit(question, selection, context) do
    ids = Enum.map(question.options, & &1.id)

    cond do
      Enum.any?(selection, &(&1 not in ids)) ->
        {:error, :invalid_option}

      question.question_type != :multiple_select and length(selection) != 1 ->
        {:error, :invalid_answer_cardinality}

      context.option_order != nil and Enum.sort(context.option_order) != Enum.sort(ids) ->
        {:error, :invalid_presentation_order}

      true ->
        :ok
    end
  end

  @spec decode_kind!(String.t()) :: kind()
  def decode_kind!(value),
    do:
      Enum.find(@kinds, &(Atom.to_string(&1) == value)) ||
        raise(ArgumentError, "invalid instrument format")

  @spec slug_base(String.t()) :: String.t()
  def slug_base(text) do
    text
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\s-]/, "")
    |> String.replace(~r/\s+/, "-")
    |> String.trim("-")
    |> String.slice(0, 100)
    |> String.trim_trailing("-")
    |> case do
      "" -> "question"
      slug -> slug
    end
  end
end
