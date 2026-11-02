defmodule Roughly.Participation.OwnershipTest do
  use ExUnit.Case, async: true
  alias Roughly.Participation.Response
  alias Roughly.Participation.Commands.{ChangeResponse, WithdrawResponse}

  test "aggregate ownership refuses forged actors even after boundary admission" do
    vote = %Response{
      uuid: "existing",
      principal_uuid: "owner",
      status: :active,
      option_ids: "Yes"
    }

    assert {:error, :not_owner} =
             Response.execute(vote, %ChangeResponse{
               response_uuid: "existing",
               actor_uuid: "other",
               new_option_ids: "No"
             })

    assert {:error, :not_owner} =
             Response.execute(vote, %WithdrawResponse{
               response_uuid: "existing",
               actor_uuid: "other"
             })
  end

  test "missing responses have defined failures rather than function clause crashes" do
    assert {:error, :response_not_found} =
             Response.execute(%Response{}, %ChangeResponse{
               response_uuid: "missing",
               actor_uuid: "owner",
               new_option_ids: "No"
             })

    assert {:error, :response_not_found} =
             Response.execute(%Response{}, %WithdrawResponse{
               response_uuid: "missing",
               actor_uuid: "owner"
             })
  end
end
