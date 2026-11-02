defmodule Roughly.Identity.Principal do
  @moduledoc "Participation continuity and standing; no credentials or demographic profile."
  alias Roughly.Identity.Commands.{RegisterPrincipal, DeactivatePrincipal}
  alias Roughly.Identity.Events.{PrincipalRegistered, PrincipalDeactivated}
  @type t :: %__MODULE__{uuid: Ecto.UUID.t() | nil, status: :active | :deactivated | nil}
  defstruct [:uuid, :status]

  @spec execute(t(), RegisterPrincipal.t() | DeactivatePrincipal.t()) ::
          PrincipalRegistered.t() | PrincipalDeactivated.t() | {:error, atom()}
  def execute(state, command)

  def execute(%__MODULE__{uuid: nil}, %RegisterPrincipal{} = cmd),
    do: %PrincipalRegistered{principal_uuid: cmd.principal_uuid}

  def execute(%__MODULE__{}, %RegisterPrincipal{}), do: {:error, :principal_already_exists}
  def execute(%__MODULE__{uuid: nil}, %DeactivatePrincipal{}), do: {:error, :principal_not_found}

  def execute(%__MODULE__{status: :active}, %DeactivatePrincipal{} = cmd),
    do: %PrincipalDeactivated{principal_uuid: cmd.principal_uuid, reason: cmd.reason}

  def execute(%__MODULE__{status: :deactivated}, %DeactivatePrincipal{}),
    do: {:error, :principal_already_deactivated}

  @spec apply(t(), PrincipalRegistered.t() | PrincipalDeactivated.t()) :: t()
  def apply(state, %PrincipalRegistered{} = event),
    do: %{state | uuid: event.principal_uuid, status: :active}

  def apply(state, %PrincipalDeactivated{}), do: %{state | status: :deactivated}
end
