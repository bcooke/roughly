defmodule Roughly.Validation do
  @moduledoc "Domain-owned command shapes. Pure parsing runs before authorization or aggregate execution."
  @commands [
    Roughly.Questions.Commands.CreateQuestion,
    Roughly.Questions.Commands.CloseQuestion,
    Roughly.Participation.Commands.RecordResponse,
    Roughly.Participation.Commands.ChangeResponse,
    Roughly.Participation.Commands.WithdrawResponse,
    Roughly.Identity.Commands.RegisterPrincipal,
    Roughly.Identity.Commands.DeactivatePrincipal,
    Roughly.Access.Commands.GrantCapability,
    Roughly.Access.Commands.RevokeCapability
  ]

  @spec parse(struct()) :: {:ok, struct()} | {:error, {:invalid_command, keyword()}}
  def parse(command) do
    errors =
      Enum.flat_map(command_rules(command), fn {field, rule} ->
        if valid?(Map.get(command, field), rule), do: [], else: [{field, :invalid}]
      end)

    if errors == [], do: {:ok, normalize(command)}, else: {:error, {:invalid_command, errors}}
  end

  defp normalize(%module{} = command) do
    if function_exported?(module, :normalize, 1), do: module.normalize(command), else: command
  end

  defp command_rules(%module{} = command) when module in @commands,
    do: module.validation_rules(command)

  defp command_rules(_), do: [__command__: {:in, []}]

  defp valid?(nil, {:optional, _}), do: true
  defp valid?(value, {:optional, rule}), do: valid?(value, rule)
  defp valid?(value, :uuid), do: is_binary(value) and match?({:ok, ^value}, Ecto.UUID.cast(value))

  defp valid?(value, {:text, max}),
    do:
      is_binary(value) and String.valid?(value) and String.trim(value) != "" and
        String.length(value) <= max

  defp valid?(value, {:in, values}), do: value in values

  defp valid?(values, {:options, type}),
    do: Roughly.Questions.Instrument.valid_options?(values, type)

  defp valid?(value, :collection_context), do: Roughly.Participation.Context.valid?(value)

  defp valid?(values, :selection) when is_list(values) do
    length(values) in 1..20 and Enum.all?(values, &valid?(&1, :uuid)) and
      Enum.uniq(values) == values
  end

  defp valid?(_, _), do: false
end
