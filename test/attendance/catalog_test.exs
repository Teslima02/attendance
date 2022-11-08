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

  describe "sessions" do
    alias Attendance.Catalog.Session

    import Attendance.CatalogFixtures

    @invalid_attrs %{description: nil, disabled: nil, end_date: nil, name: nil, start_date: nil}

    test "list_sessions/0 returns all sessions" do
      session = session_fixture()
      assert Catalog.list_sessions() == [session]
    end

    test "get_session!/1 returns the session with given id" do
      session = session_fixture()
      assert Catalog.get_session!(session.id) == session
    end

    test "create_session/1 with valid data creates a session" do
      valid_attrs = %{description: "some description", disabled: true, end_date: ~N[2022-11-04 16:25:00], name: "some name", start_date: ~N[2022-11-04 16:25:00]}

      assert {:ok, %Session{} = session} = Catalog.create_session(valid_attrs)
      assert session.description == "some description"
      assert session.disabled == true
      assert session.end_date == ~N[2022-11-04 16:25:00]
      assert session.name == "some name"
      assert session.start_date == ~N[2022-11-04 16:25:00]
    end

    test "create_session/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_session(@invalid_attrs)
    end

    test "update_session/2 with valid data updates the session" do
      session = session_fixture()
      update_attrs = %{description: "some updated description", disabled: false, end_date: ~N[2022-11-05 16:25:00], name: "some updated name", start_date: ~N[2022-11-05 16:25:00]}

      assert {:ok, %Session{} = session} = Catalog.update_session(session, update_attrs)
      assert session.description == "some updated description"
      assert session.disabled == false
      assert session.end_date == ~N[2022-11-05 16:25:00]
      assert session.name == "some updated name"
      assert session.start_date == ~N[2022-11-05 16:25:00]
    end

    test "update_session/2 with invalid data returns error changeset" do
      session = session_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.update_session(session, @invalid_attrs)
      assert session == Catalog.get_session!(session.id)
    end

    test "delete_session/1 deletes the session" do
      session = session_fixture()
      assert {:ok, %Session{}} = Catalog.delete_session(session)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_session!(session.id) end
    end

    test "change_session/1 returns a session changeset" do
      session = session_fixture()
      assert %Ecto.Changeset{} = Catalog.change_session(session)
    end
  end
end
