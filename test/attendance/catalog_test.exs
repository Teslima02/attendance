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

  describe "semesters" do
    alias Attendance.Catalog.Semester

    import Attendance.CatalogFixtures

    @invalid_attrs %{disabled: nil, end_date: nil, name: nil, start_date: nil}

    test "list_semesters/0 returns all semesters" do
      semester = semester_fixture()
      assert Catalog.list_semesters() == [semester]
    end

    test "get_semester!/1 returns the semester with given id" do
      semester = semester_fixture()
      assert Catalog.get_semester!(semester.id) == semester
    end

    test "create_semester/1 with valid data creates a semester" do
      valid_attrs = %{disabled: true, end_date: ~D[2022-11-07], name: "some name", start_date: ~D[2022-11-07]}

      assert {:ok, %Semester{} = semester} = Catalog.create_semester(valid_attrs)
      assert semester.disabled == true
      assert semester.end_date == ~D[2022-11-07]
      assert semester.name == "some name"
      assert semester.start_date == ~D[2022-11-07]
    end

    test "create_semester/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_semester(@invalid_attrs)
    end

    test "update_semester/2 with valid data updates the semester" do
      semester = semester_fixture()
      update_attrs = %{disabled: false, end_date: ~D[2022-11-08], name: "some updated name", start_date: ~D[2022-11-08]}

      assert {:ok, %Semester{} = semester} = Catalog.update_semester(semester, update_attrs)
      assert semester.disabled == false
      assert semester.end_date == ~D[2022-11-08]
      assert semester.name == "some updated name"
      assert semester.start_date == ~D[2022-11-08]
    end

    test "update_semester/2 with invalid data returns error changeset" do
      semester = semester_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.update_semester(semester, @invalid_attrs)
      assert semester == Catalog.get_semester!(semester.id)
    end

    test "delete_semester/1 deletes the semester" do
      semester = semester_fixture()
      assert {:ok, %Semester{}} = Catalog.delete_semester(semester)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_semester!(semester.id) end
    end

    test "change_semester/1 returns a semester changeset" do
      semester = semester_fixture()
      assert %Ecto.Changeset{} = Catalog.change_semester(semester)
    end
  end

  describe "classes" do
    alias Attendance.Catalog.Class

    import Attendance.CatalogFixtures

    @invalid_attrs %{disabled: nil, name: nil}

    test "list_classes/0 returns all classes" do
      class = class_fixture()
      assert Catalog.list_classes() == [class]
    end

    test "get_class!/1 returns the class with given id" do
      class = class_fixture()
      assert Catalog.get_class!(class.id) == class
    end

    test "create_class/1 with valid data creates a class" do
      valid_attrs = %{disabled: true, name: "some name"}

      assert {:ok, %Class{} = class} = Catalog.create_class(valid_attrs)
      assert class.disabled == true
      assert class.name == "some name"
    end

    test "create_class/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_class(@invalid_attrs)
    end

    test "update_class/2 with valid data updates the class" do
      class = class_fixture()
      update_attrs = %{disabled: false, name: "some updated name"}

      assert {:ok, %Class{} = class} = Catalog.update_class(class, update_attrs)
      assert class.disabled == false
      assert class.name == "some updated name"
    end

    test "update_class/2 with invalid data returns error changeset" do
      class = class_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.update_class(class, @invalid_attrs)
      assert class == Catalog.get_class!(class.id)
    end

    test "delete_class/1 deletes the class" do
      class = class_fixture()
      assert {:ok, %Class{}} = Catalog.delete_class(class)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_class!(class.id) end
    end

    test "change_class/1 returns a class changeset" do
      class = class_fixture()
      assert %Ecto.Changeset{} = Catalog.change_class(class)
    end
  end

  describe "periods" do
    alias Attendance.Catalog.Period

    import Attendance.CatalogFixtures

    @invalid_attrs %{disabled: nil, end_time: nil, start_time: nil}

    test "list_periods/0 returns all periods" do
      period = period_fixture()
      assert Catalog.list_periods() == [period]
    end

    test "get_period!/1 returns the period with given id" do
      period = period_fixture()
      assert Catalog.get_period!(period.id) == period
    end

    test "create_period/1 with valid data creates a period" do
      valid_attrs = %{disabled: true, end_time: ~T[14:00:00], start_time: ~T[14:00:00]}

      assert {:ok, %Period{} = period} = Catalog.create_period(valid_attrs)
      assert period.disabled == true
      assert period.end_time == ~T[14:00:00]
      assert period.start_time == ~T[14:00:00]
    end

    test "create_period/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_period(@invalid_attrs)
    end

    test "update_period/2 with valid data updates the period" do
      period = period_fixture()
      update_attrs = %{disabled: false, end_time: ~T[15:01:01], start_time: ~T[15:01:01]}

      assert {:ok, %Period{} = period} = Catalog.update_period(period, update_attrs)
      assert period.disabled == false
      assert period.end_time == ~T[15:01:01]
      assert period.start_time == ~T[15:01:01]
    end

    test "update_period/2 with invalid data returns error changeset" do
      period = period_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.update_period(period, @invalid_attrs)
      assert period == Catalog.get_period!(period.id)
    end

    test "delete_period/1 deletes the period" do
      period = period_fixture()
      assert {:ok, %Period{}} = Catalog.delete_period(period)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_period!(period.id) end
    end

    test "change_period/1 returns a period changeset" do
      period = period_fixture()
      assert %Ecto.Changeset{} = Catalog.change_period(period)
    end
  end

  describe "days_of_weeks" do
    alias Attendance.Catalog.Days_of_week

    import Attendance.CatalogFixtures

    @invalid_attrs %{disabled: nil, name: nil}

    test "list_days_of_weeks/0 returns all days_of_weeks" do
      days_of_week = days_of_week_fixture()
      assert Catalog.list_days_of_weeks() == [days_of_week]
    end

    test "get_days_of_week!/1 returns the days_of_week with given id" do
      days_of_week = days_of_week_fixture()
      assert Catalog.get_days_of_week!(days_of_week.id) == days_of_week
    end

    test "create_days_of_week/1 with valid data creates a days_of_week" do
      valid_attrs = %{disabled: true, name: "some name"}

      assert {:ok, %Days_of_week{} = days_of_week} = Catalog.create_days_of_week(valid_attrs)
      assert days_of_week.disabled == true
      assert days_of_week.name == "some name"
    end

    test "create_days_of_week/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_days_of_week(@invalid_attrs)
    end

    test "update_days_of_week/2 with valid data updates the days_of_week" do
      days_of_week = days_of_week_fixture()
      update_attrs = %{disabled: false, name: "some updated name"}

      assert {:ok, %Days_of_week{} = days_of_week} = Catalog.update_days_of_week(days_of_week, update_attrs)
      assert days_of_week.disabled == false
      assert days_of_week.name == "some updated name"
    end

    test "update_days_of_week/2 with invalid data returns error changeset" do
      days_of_week = days_of_week_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.update_days_of_week(days_of_week, @invalid_attrs)
      assert days_of_week == Catalog.get_days_of_week!(days_of_week.id)
    end

    test "delete_days_of_week/1 deletes the days_of_week" do
      days_of_week = days_of_week_fixture()
      assert {:ok, %Days_of_week{}} = Catalog.delete_days_of_week(days_of_week)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_days_of_week!(days_of_week.id) end
    end

    test "change_days_of_week/1 returns a days_of_week changeset" do
      days_of_week = days_of_week_fixture()
      assert %Ecto.Changeset{} = Catalog.change_days_of_week(days_of_week)
    end
  end
end
