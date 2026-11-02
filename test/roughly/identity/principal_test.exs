defmodule Roughly.Identity.PrincipalTest do
  use ExUnit.Case, async: true
  alias Roughly.Identity.Principal
  alias Roughly.Identity.Commands.{RegisterPrincipal, DeactivatePrincipal}
  alias Roughly.Identity.Events.{PrincipalRegistered, PrincipalDeactivated}

  test "registration establishes continuity, duplicate registration is refused" do
    id = Ecto.UUID.generate()
    event = Principal.execute(%Principal{}, %RegisterPrincipal{principal_uuid: id})
    assert event == %PrincipalRegistered{principal_uuid: id}
    principal = Principal.apply(%Principal{}, event)
    assert principal == %Principal{uuid: id, status: :active}

    assert {:error, :principal_already_exists} =
             Principal.execute(principal, %RegisterPrincipal{principal_uuid: id})
  end

  test "deactivation is explicit and has defined missing and duplicate outcomes" do
    id = Ecto.UUID.generate()
    command = %DeactivatePrincipal{principal_uuid: id}
    assert {:error, :principal_not_found} = Principal.execute(%Principal{}, command)
    event = Principal.execute(%Principal{uuid: id, status: :active}, command)
    assert %PrincipalDeactivated{principal_uuid: ^id} = event
    state = Principal.apply(%Principal{uuid: id}, event)
    assert {:error, :principal_already_deactivated} = Principal.execute(state, command)
  end
end
