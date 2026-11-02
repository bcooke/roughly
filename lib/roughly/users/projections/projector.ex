defmodule Roughly.Users.Projections.Projector do
  @moduledoc """
  Projector for the Users domain.

  Listens to user events and updates the read model.
  """

  use Commanded.Projections.Ecto,
    application: Roughly.App,
    repo: Roughly.Repo,
    name: "UserProjector"

  alias Roughly.Users.Events.{UserRegistered, ProfileUpdated, UserDeactivated}
  alias Roughly.Users.Projections.User

  project(%UserRegistered{} = event, _metadata, fn multi ->
    Ecto.Multi.insert(multi, :user, %User{
      uuid: event.user_uuid,
      email: event.email,
      password_hash: event.password_hash,
      status: :active
    })
  end)

  project(%ProfileUpdated{} = event, _metadata, fn multi ->
    Ecto.Multi.run(multi, :user, fn repo, _changes ->
      case repo.get(User, event.user_uuid) do
        nil ->
          {:error, :not_found}

        user ->
          attrs =
            %{
              display_name: event.display_name,
              birth_year: event.birth_year,
              country: event.country,
              region: event.region,
              gender: event.gender
            }
            |> Enum.reject(fn {_k, v} -> is_nil(v) end)
            |> Map.new()

          user
          |> Ecto.Changeset.change(attrs)
          |> repo.update()
      end
    end)
  end)

  project(%UserDeactivated{} = event, _metadata, fn multi ->
    Ecto.Multi.run(multi, :user, fn repo, _changes ->
      case repo.get(User, event.user_uuid) do
        nil ->
          {:error, :not_found}

        user ->
          user
          |> Ecto.Changeset.change(status: :deactivated)
          |> repo.update()
      end
    end)
  end)
end
