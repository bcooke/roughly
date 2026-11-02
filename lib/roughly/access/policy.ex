defmodule Roughly.Access.Policy do
  @moduledoc "Fail-closed command admission. Capability grants and account standing are read from event history."
  alias Roughly.Access.Actor
  alias Roughly.Access.Commands.{GrantCapability, RevokeCapability}
  alias Roughly.Questions.Commands.{CreateQuestion, CloseQuestion}
  alias Roughly.Identity.Commands.{RegisterPrincipal, DeactivatePrincipal}
  alias Roughly.Participation.Commands.{RecordResponse, ChangeResponse, WithdrawResponse}

  @spec authorize(struct(), Actor.t()) :: {:ok, struct()} | {:error, atom()}
  def authorize(command, actor) do
    with :ok <- actor_allowed(actor),
         :ok <- capability(command, actor) do
      ownership(command, actor)
    end
  end

  defp actor_allowed(%Actor{kind: :principal, id: id}) do
    if match?({:ok, ^id}, Ecto.UUID.cast(id)) do
      if Roughly.Identity.active?(id), do: :ok, else: {:error, :inactive_actor}
    else
      {:error, :unauthorized}
    end
  end

  defp actor_allowed(%Actor{kind: :system, source: source}) do
    if Map.has_key?(Application.get_env(:roughly, :system_capabilities, %{}), source),
      do: :ok,
      else: {:error, :forbidden}
  end

  defp actor_allowed(_), do: {:error, :unauthorized}

  defp capability(command, actor) do
    required = required_capability(command)
    capabilities = permissions(actor)

    seed? =
      :seed in capabilities and Application.get_env(:roughly, :allow_dev_seeds, false) and
        seed_command?(command)

    if seed? or required in capabilities, do: :ok, else: {:error, :forbidden}
  end

  defp permissions(%Actor{kind: :system, source: source}),
    do: Map.get(Application.get_env(:roughly, :system_capabilities, %{}), source, [])

  defp permissions(%Actor{kind: :principal, id: id}) do
    grants = Roughly.Access.capabilities(id)

    [:self] ++
      Enum.filter(
        [:curate_questions, :manage_access],
        &MapSet.member?(grants, Atom.to_string(&1))
      )
  end

  defp required_capability(%CreateQuestion{}), do: :curate_questions
  defp required_capability(%CloseQuestion{}), do: :curate_questions
  defp required_capability(%GrantCapability{}), do: :manage_access
  defp required_capability(%RevokeCapability{}), do: :manage_access
  defp required_capability(%RegisterPrincipal{}), do: :register_principals
  defp required_capability(%RecordResponse{}), do: :self
  defp required_capability(%ChangeResponse{}), do: :self
  defp required_capability(%WithdrawResponse{}), do: :self
  defp required_capability(%DeactivatePrincipal{}), do: :self
  defp required_capability(_), do: :unclassified

  defp seed_command?(%CreateQuestion{}), do: true
  defp seed_command?(%RegisterPrincipal{}), do: true
  defp seed_command?(%RecordResponse{}), do: true
  defp seed_command?(_), do: false

  defp ownership(%CreateQuestion{} = cmd, actor), do: bind(cmd, :created_by, actor.id)
  defp ownership(%CloseQuestion{} = cmd, actor), do: bind(cmd, :closed_by, actor.id)

  defp ownership(%RecordResponse{} = cmd, actor),
    do: Roughly.Participation.Admission.admit(cmd, actor)

  defp ownership(%ChangeResponse{} = cmd, actor),
    do: Roughly.Participation.Admission.admit(cmd, actor)

  defp ownership(%WithdrawResponse{} = cmd, actor),
    do: Roughly.Participation.Admission.admit(cmd, actor)

  defp ownership(%GrantCapability{} = cmd, _actor), do: active_subject(cmd)
  defp ownership(%RevokeCapability{} = cmd, _actor), do: active_subject(cmd)
  defp ownership(%DeactivatePrincipal{principal_uuid: id} = cmd, %Actor{id: id}), do: {:ok, cmd}
  defp ownership(%DeactivatePrincipal{}, _), do: {:error, :not_owner}
  defp ownership(command, _), do: {:ok, command}

  defp bind(cmd, field, id) do
    if Map.get(cmd, field) in [nil, id],
      do: {:ok, Map.put(cmd, field, id)},
      else: {:error, :not_owner}
  end

  defp active_subject(cmd) do
    if Roughly.Identity.active?(cmd.principal_uuid),
      do: {:ok, cmd},
      else: {:error, :principal_not_found}
  end
end
