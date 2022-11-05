defmodule Attendance.CatalogTest do
  use Attendance.DataCase

  alias Attendance.Catalog
  alias Attendance.AccountsFixtures

  def setup_admin(_) do
    admin = AccountsFixtures.admin_fixture()
    {:ok, admin: admin}
  end

  describe "programs" do
    alias Attendance.Catalog.Program

    import Attendance.CatalogFixtures

    @invalid_attrs %{description: nil, disabled: nil, name: nil}

    setup [:setup_admin]

    test "list_programs/0 returns all programs" do
      program = program_fixture()
      assert Catalog.list_programs() == [program]
    end

    test "get_program!/1 returns the program with given id" do
      program = program_fixture()
      assert Catalog.get_program!(program.id) == program
    end

    test "create_program/1 with valid data creates a program", %{admin: admin} do
      valid_attrs = %{description: "some description", disabled: true, name: "some name"}

      assert {:ok, %Program{} = program} = Catalog.create_program(admin, valid_attrs)
      assert program.description == "some description"
      assert program.disabled == true
      assert program.name == "some name"
    end

    test "create_program/1 with invalid data returns error changeset", %{admin: admin} do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_program(admin, @invalid_attrs)
    end

    test "update_program/2 with valid data updates the program" do
      program = program_fixture()
      update_attrs = %{description: "some updated description", disabled: false, name: "some updated name"}

      assert {:ok, %Program{} = program} = Catalog.update_program(program, update_attrs)
      assert program.description == "some updated description"
      assert program.disabled == false
      assert program.name == "some updated name"
    end

    test "update_program/2 with invalid data returns error changeset" do
      program = program_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.update_program(program, @invalid_attrs)
      assert program == Catalog.get_program!(program.id)
    end

    test "delete_program/1 deletes the program" do
      program = program_fixture()
      assert {:ok, %Program{}} = Catalog.delete_program(program)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_program!(program.id) end
    end

    test "change_program/1 returns a program changeset" do
      program = program_fixture()
      assert %Ecto.Changeset{} = Catalog.change_program(program)
    end
  end
end
