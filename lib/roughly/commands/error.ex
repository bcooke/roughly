defmodule Roughly.Commands.Error do
  @moduledoc """
  Standard error structure for command operations.

  This module provides a consistent error format across all commands,
  making error handling and propagation predictable throughout the application.
  Particularly important for Ecto.Multi compatibility and consistent API responses.

  ## Usage

      # Create simple error
      Error.new(:not_found)

      # Create error with message
      Error.new(:validation_failed, "Email is invalid")

      # Create error with changeset
      Error.new(:validation_failed, changeset)

      # Format error for display
      Error.format(error)
  """

  @type t :: %__MODULE__{
          reason: atom(),
          message: String.t() | nil,
          changeset: Ecto.Changeset.t() | nil,
          details: map() | nil
        }

  @derive {Jason.Encoder, only: [:reason, :message, :details]}
  defstruct [:reason, :message, :changeset, :details]

  @doc """
  Creates a new error with just a reason.
  """
  @spec new(atom()) :: t()
  def new(reason) when is_atom(reason), do: %__MODULE__{reason: reason}

  @doc """
  Creates a new error with a reason and message/changeset/details.
  """
  @spec new(atom(), String.t() | Ecto.Changeset.t() | map()) :: t()
  def new(reason, message) when is_atom(reason) and is_binary(message),
    do: %__MODULE__{reason: reason, message: message}

  def new(reason, %Ecto.Changeset{} = changeset) when is_atom(reason),
    do: %__MODULE__{reason: reason, changeset: changeset}

  def new(reason, details) when is_atom(reason) and is_map(details),
    do: %__MODULE__{reason: reason, details: details}

  @doc """
  Returns a formatted error message.

  If a message is present, it's returned directly.
  If a changeset is present, its errors are formatted.
  Otherwise, the reason is converted to a string.
  """
  @spec format(t()) :: String.t()
  def format(%__MODULE__{message: message}) when is_binary(message), do: message

  def format(%__MODULE__{changeset: changeset}) when not is_nil(changeset),
    do: format_validation_errors(changeset)

  def format(%__MODULE__{reason: reason}), do: humanize_reason(reason)

  @doc """
  Formats changeset validation errors into a user-friendly message string.
  """
  @spec format_validation_errors(Ecto.Changeset.t()) :: String.t()
  def format_validation_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.map(fn {field, errors} ->
      "#{humanize_field(field)} #{Enum.join(errors, " and ")}"
    end)
    |> Enum.join(", ")
  end

  @doc """
  Extracts the reason from the error.
  """
  @spec reason(t()) :: atom()
  def reason(%__MODULE__{reason: reason}), do: reason

  @doc """
  Extracts the message from the error if available.
  """
  @spec message(t()) :: String.t() | nil
  def message(%__MODULE__{message: message}), do: message

  @doc """
  Extracts the changeset from the error if available.
  """
  @spec changeset(t()) :: Ecto.Changeset.t() | nil
  def changeset(%__MODULE__{changeset: changeset}), do: changeset

  @doc """
  Returns true if the error is of the specified reason.
  """
  @spec reason?(t(), atom()) :: boolean()
  def reason?(%__MODULE__{reason: error_reason}, reason), do: error_reason == reason

  # Convenience constructors for common error patterns

  @doc "Creates a not found error."
  @spec not_found(String.t()) :: t()
  def not_found(message \\ "Resource not found"), do: new(:not_found, message)

  @doc "Creates a validation error."
  @spec validation_error(String.t() | Ecto.Changeset.t()) :: t()
  def validation_error(message_or_changeset),
    do: new(:validation_failed, message_or_changeset)

  @doc "Creates a forbidden/unauthorized error."
  @spec forbidden(String.t()) :: t()
  def forbidden(message \\ "Access denied"), do: new(:forbidden, message)

  @doc "Creates an internal error."
  @spec internal_error(String.t()) :: t()
  def internal_error(message \\ "An unexpected error occurred"),
    do: new(:internal_error, message)

  @doc "Creates a duplicate error."
  @spec duplicate(String.t()) :: t()
  def duplicate(message \\ "Resource already exists"), do: new(:duplicate, message)

  # Private helpers

  defp humanize_reason(reason) do
    reason
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end

  defp humanize_field(field) do
    field
    |> Atom.to_string()
    |> String.replace("_", " ")
  end
end
