defmodule Roughly.Architecture.IdentityBoundaryTest do
  use ExUnit.Case, async: true

  test "the principal registration event carries no credentials or profile data" do
    fields =
      Roughly.Identity.Events.PrincipalRegistered.__struct__() |> Map.from_struct() |> Map.keys()

    assert fields == [:principal_uuid]
  end
end
