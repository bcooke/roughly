defmodule Roughly.Users.User do
  @moduledoc """
  User aggregate - represents a participant in the system.

  Users have demographic attributes that enable population slicing.
  """

  defstruct [:uuid, :demographic_attributes, :status]

  # Commands (to be implemented)
  # - RegisterUser
  # - UpdateDemographics
  # - DeactivateUser

  # Events (to be implemented)
  # - UserRegistered
  # - DemographicsUpdated
  # - UserDeactivated
end
