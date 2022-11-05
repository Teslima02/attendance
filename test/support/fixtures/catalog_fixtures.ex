defmodule Attendance.CatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Attendance.Catalog` context.
  """

  alias Attendance.AccountsFixtures

  @doc """
  Generate a unique program name.
  """
  def unique_program_name, do: "some name#{System.unique_integer([:positive])}"

  @doc """
  Generate a program.
  """
  def program_fixture(attrs \\ %{}) do
    
      attrs =
      Enum.into(attrs, %{
        description: "some description",
        disabled: true,
        name: unique_program_name()
      })

      admin = AccountsFixtures.admin_fixture()
      {:ok, program} = Attendance.Catalog.create_program(admin, attrs)

    program
  end
end
