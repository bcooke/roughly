defmodule Roughly.Router do
  @moduledoc """
  Command router for Roughly.

  Routes commands to their respective aggregates.
  """

  use Commanded.Commands.Router

  alias Roughly.Questions.Question
  alias Roughly.Questions.Commands.{CreateQuestion, CloseQuestion}

  alias Roughly.Participation.Response
  alias Roughly.Participation.Commands.{RecordResponse, WithdrawResponse, ChangeResponse}

  alias Roughly.Identity.Principal
  alias Roughly.Identity.Commands.{RegisterPrincipal, DeactivatePrincipal}

  # Middlewares
  middleware(Roughly.Validation.Middleware)
  middleware(Roughly.Access.Middleware)
  middleware(Commanded.Middleware.Logger)

  dispatch([Roughly.Access.Commands.GrantCapability, Roughly.Access.Commands.RevokeCapability],
    to: Roughly.Access.Grants,
    identity: :principal_uuid,
    identity_prefix: "access-"
  )

  dispatch(Roughly.Questions.Commands.ClaimSlug,
    to: Roughly.Questions.Slug,
    identity: :slug,
    identity_prefix: "question-slug:"
  )

  # Questions
  dispatch([CreateQuestion, CloseQuestion], to: Question, identity: :question_uuid)

  # Participation
  dispatch([RecordResponse, WithdrawResponse, ChangeResponse],
    to: Response,
    identity: :response_uuid
  )

  # Identity
  dispatch([RegisterPrincipal, DeactivatePrincipal], to: Principal, identity: :principal_uuid)
end
