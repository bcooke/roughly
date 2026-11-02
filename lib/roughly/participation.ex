defmodule Roughly.Participation do
  @moduledoc "Participation entry points. One stable response stream per question/principal under the current collection policy."
  alias Roughly.Access.Actor
  alias Roughly.Participation.Commands.{RecordResponse, ChangeResponse, WithdrawResponse}

  @spec record(Actor.t(), Ecto.UUID.t(), [Ecto.UUID.t()], Roughly.Participation.Context.t()) ::
          {:ok, Ecto.UUID.t()} | {:error, term()}
  def record(actor, question_uuid, option, context \\ %Roughly.Participation.Context{}) do
    id = identity(question_uuid, actor.id)

    case Roughly.Dispatch.dispatch(
           %RecordResponse{
             response_uuid: id,
             question_uuid: question_uuid,
             principal_uuid: actor.id,
             option_ids: option,
             context: context
           },
           actor
         ) do
      :ok -> {:ok, id}
      error -> error
    end
  end

  @spec change(Actor.t(), Ecto.UUID.t(), [Ecto.UUID.t()], Roughly.Participation.Context.t()) ::
          :ok | {:error, term()}
  def change(actor, id, option, context \\ %Roughly.Participation.Context{}),
    do:
      Roughly.Dispatch.dispatch(
        %ChangeResponse{
          response_uuid: id,
          new_option_ids: option,
          actor_uuid: actor.id,
          context: context
        },
        actor
      )

  @spec withdraw(Actor.t(), Ecto.UUID.t()) :: :ok | {:error, term()}
  def withdraw(actor, id),
    do:
      Roughly.Dispatch.dispatch(%WithdrawResponse{response_uuid: id, actor_uuid: actor.id}, actor)

  @spec identity(String.t(), String.t() | nil) :: Ecto.UUID.t()
  def identity(question, principal) do
    <<a::32, b::16, _::4, c::12, _::2, d::62, _::binary>> =
      :crypto.hash(:sha256, "roughly-response-v1:#{question}:#{principal}")

    Ecto.UUID.load!(<<a::32, b::16, 8::4, c::12, 2::2, d::62>>)
  end
end
