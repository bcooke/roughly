defmodule Roughly.Participation.Admission do
  @moduledoc "Participation owns response identity, ownership and instrument eligibility."
  alias Roughly.Access.Actor

  alias Roughly.Participation.{
    Response,
    Commands.RecordResponse,
    Commands.ChangeResponse,
    Commands.WithdrawResponse
  }

  @spec admit(RecordResponse.t() | ChangeResponse.t() | WithdrawResponse.t(), Actor.t()) ::
          {:ok, struct()} | {:error, atom()}
  def admit(%RecordResponse{} = command, actor) do
    with :ok <- active_principal(command.principal_uuid),
         :ok <- response_identity(command, actor),
         :ok <-
           Roughly.Questions.admit_answer(
             command.question_uuid,
             command.option_ids,
             command.context
           ) do
      {:ok, command}
    end
  end

  def admit(%ChangeResponse{} = command, actor) do
    with {:ok, response} <- owned_response(command.response_uuid, actor),
         {:ok, command} <- bind_actor(command, actor),
         :ok <-
           Roughly.Questions.admit_answer(
             response.question_uuid,
             command.new_option_ids,
             command.context
           ) do
      {:ok, command}
    end
  end

  def admit(%WithdrawResponse{} = command, actor) do
    with {:ok, _vote} <- owned_response(command.response_uuid, actor) do
      bind_actor(command, actor)
    end
  end

  defp active_principal(id) do
    if Roughly.Identity.active?(id), do: :ok, else: {:error, :principal_not_found}
  end

  defp response_identity(cmd, actor) do
    cond do
      actor.kind == :principal and cmd.principal_uuid != actor.id ->
        {:error, :not_owner}

      cmd.response_uuid != Roughly.Participation.identity(cmd.question_uuid, cmd.principal_uuid) ->
        {:error, :invalid_response_identity}

      true ->
        :ok
    end
  end

  defp owned_response(id, actor) do
    case Roughly.History.load(Response, id) do
      %Response{uuid: nil} -> {:error, :response_not_found}
      %Response{principal_uuid: owner} = response when owner == actor.id -> {:ok, response}
      _ -> {:error, :not_owner}
    end
  end

  defp bind_actor(cmd, actor) do
    if cmd.actor_uuid in [nil, actor.id],
      do: {:ok, %{cmd | actor_uuid: actor.id}},
      else: {:error, :not_owner}
  end
end
