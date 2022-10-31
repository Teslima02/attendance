defmodule Attendance.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Attendance.Accounts` context.
  """

  def unique_first_name, do: "admin#{System.unique_integer()}@example.com"
  def unique_middle_name, do: "admin#{System.unique_integer()}@example.com"
  def unique_last_name, do: "admin#{System.unique_integer()}@example.com"
  def unique_admin_email, do: "admin#{System.unique_integer()}@example.com"
  def valid_admin_password, do: "Password@123"

  def valid_admin_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      first_name: unique_first_name(),
      middle_name: unique_middle_name(),
      last_name: unique_last_name(),
      disabled: false,
      email: unique_admin_email(),
      password: valid_admin_password()
    })
  end

  def admin_fixture(attrs \\ %{}) do
    {:ok, admin} =
      attrs
      |> valid_admin_attributes()
      |> Attendance.Accounts.register_admin()

    admin
  end

  def extract_admin_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
