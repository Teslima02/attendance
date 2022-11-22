defmodule Attendance.LecturersTest do
  use Attendance.DataCase

  alias Attendance.Lecturers

  import Attendance.LecturersFixtures
  alias Attendance.Lecturers.{Lecturer, LecturerToken}

  describe "get_lecturer_by_email/1" do
    test "does not return the lecturer if the email does not exist" do
      refute Lecturers.get_lecturer_by_email("unknown@example.com")
    end

    test "returns the lecturer if the email exists" do
      %{id: id} = lecturer = lecturer_fixture()
      assert %Lecturer{id: ^id} = Lecturers.get_lecturer_by_email(lecturer.email)
    end
  end

  describe "get_lecturer_by_email_and_password/2" do
    test "does not return the lecturer if the email does not exist" do
      refute Lecturers.get_lecturer_by_email_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the lecturer if the password is not valid" do
      lecturer = lecturer_fixture()
      refute Lecturers.get_lecturer_by_email_and_password(lecturer.email, "invalid")
    end

    test "returns the lecturer if the email and password are valid" do
      %{id: id} = lecturer = lecturer_fixture()

      assert %Lecturer{id: ^id} =
               Lecturers.get_lecturer_by_email_and_password(lecturer.email, valid_lecturer_password())
    end
  end

  describe "get_lecturer!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Lecturers.get_lecturer!(-1)
      end
    end

    test "returns the lecturer with the given id" do
      %{id: id} = lecturer = lecturer_fixture()
      assert %Lecturer{id: ^id} = Lecturers.get_lecturer!(lecturer.id)
    end
  end

  describe "register_lecturer/1" do
    test "requires email and password to be set" do
      {:error, changeset} = Lecturers.register_lecturer(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates email and password when given" do
      {:error, changeset} = Lecturers.register_lecturer(%{email: "not valid", password: "not valid"})

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: ["should be at least 12 character(s)"]
             } = errors_on(changeset)
    end

    test "validates maximum values for email and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Lecturers.register_lecturer(%{email: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates email uniqueness" do
      %{email: email} = lecturer_fixture()
      {:error, changeset} = Lecturers.register_lecturer(%{email: email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset} = Lecturers.register_lecturer(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(changeset).email
    end

    test "registers lecturers with a hashed password" do
      email = unique_lecturer_email()
      {:ok, lecturer} = Lecturers.register_lecturer(valid_lecturer_attributes(email: email))
      assert lecturer.email == email
      assert is_binary(lecturer.hashed_password)
      assert is_nil(lecturer.confirmed_at)
      assert is_nil(lecturer.password)
    end
  end

  describe "change_lecturer_registration/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Lecturers.change_lecturer_registration(%Lecturer{})
      assert changeset.required == [:password, :email]
    end

    test "allows fields to be set" do
      email = unique_lecturer_email()
      password = valid_lecturer_password()

      changeset =
        Lecturers.change_lecturer_registration(
          %Lecturer{},
          valid_lecturer_attributes(email: email, password: password)
        )

      assert changeset.valid?
      assert get_change(changeset, :email) == email
      assert get_change(changeset, :password) == password
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "change_lecturer_email/2" do
    test "returns a lecturer changeset" do
      assert %Ecto.Changeset{} = changeset = Lecturers.change_lecturer_email(%Lecturer{})
      assert changeset.required == [:email]
    end
  end

  describe "apply_lecturer_email/3" do
    setup do
      %{lecturer: lecturer_fixture()}
    end

    test "requires email to change", %{lecturer: lecturer} do
      {:error, changeset} = Lecturers.apply_lecturer_email(lecturer, valid_lecturer_password(), %{})
      assert %{email: ["did not change"]} = errors_on(changeset)
    end

    test "validates email", %{lecturer: lecturer} do
      {:error, changeset} =
        Lecturers.apply_lecturer_email(lecturer, valid_lecturer_password(), %{email: "not valid"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates maximum value for email for security", %{lecturer: lecturer} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Lecturers.apply_lecturer_email(lecturer, valid_lecturer_password(), %{email: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).email
    end

    test "validates email uniqueness", %{lecturer: lecturer} do
      %{email: email} = lecturer_fixture()

      {:error, changeset} =
        Lecturers.apply_lecturer_email(lecturer, valid_lecturer_password(), %{email: email})

      assert "has already been taken" in errors_on(changeset).email
    end

    test "validates current password", %{lecturer: lecturer} do
      {:error, changeset} =
        Lecturers.apply_lecturer_email(lecturer, "invalid", %{email: unique_lecturer_email()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "applies the email without persisting it", %{lecturer: lecturer} do
      email = unique_lecturer_email()
      {:ok, lecturer} = Lecturers.apply_lecturer_email(lecturer, valid_lecturer_password(), %{email: email})
      assert lecturer.email == email
      assert Lecturers.get_lecturer!(lecturer.id).email != email
    end
  end

  describe "deliver_update_email_instructions/3" do
    setup do
      %{lecturer: lecturer_fixture()}
    end

    test "sends token through notification", %{lecturer: lecturer} do
      token =
        extract_lecturer_token(fn url ->
          Lecturers.deliver_update_email_instructions(lecturer, "current@example.com", url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert lecturer_token = Repo.get_by(LecturerToken, token: :crypto.hash(:sha256, token))
      assert lecturer_token.lecturer_id == lecturer.id
      assert lecturer_token.sent_to == lecturer.email
      assert lecturer_token.context == "change:current@example.com"
    end
  end

  describe "update_lecturer_email/2" do
    setup do
      lecturer = lecturer_fixture()
      email = unique_lecturer_email()

      token =
        extract_lecturer_token(fn url ->
          Lecturers.deliver_update_email_instructions(%{lecturer | email: email}, lecturer.email, url)
        end)

      %{lecturer: lecturer, token: token, email: email}
    end

    test "updates the email with a valid token", %{lecturer: lecturer, token: token, email: email} do
      assert Lecturers.update_lecturer_email(lecturer, token) == :ok
      changed_lecturer = Repo.get!(Lecturer, lecturer.id)
      assert changed_lecturer.email != lecturer.email
      assert changed_lecturer.email == email
      assert changed_lecturer.confirmed_at
      assert changed_lecturer.confirmed_at != lecturer.confirmed_at
      refute Repo.get_by(LecturerToken, lecturer_id: lecturer.id)
    end

    test "does not update email with invalid token", %{lecturer: lecturer} do
      assert Lecturers.update_lecturer_email(lecturer, "oops") == :error
      assert Repo.get!(Lecturer, lecturer.id).email == lecturer.email
      assert Repo.get_by(LecturerToken, lecturer_id: lecturer.id)
    end

    test "does not update email if lecturer email changed", %{lecturer: lecturer, token: token} do
      assert Lecturers.update_lecturer_email(%{lecturer | email: "current@example.com"}, token) == :error
      assert Repo.get!(Lecturer, lecturer.id).email == lecturer.email
      assert Repo.get_by(LecturerToken, lecturer_id: lecturer.id)
    end

    test "does not update email if token expired", %{lecturer: lecturer, token: token} do
      {1, nil} = Repo.update_all(LecturerToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Lecturers.update_lecturer_email(lecturer, token) == :error
      assert Repo.get!(Lecturer, lecturer.id).email == lecturer.email
      assert Repo.get_by(LecturerToken, lecturer_id: lecturer.id)
    end
  end

  describe "change_lecturer_password/2" do
    test "returns a lecturer changeset" do
      assert %Ecto.Changeset{} = changeset = Lecturers.change_lecturer_password(%Lecturer{})
      assert changeset.required == [:password]
    end

    test "allows fields to be set" do
      changeset =
        Lecturers.change_lecturer_password(%Lecturer{}, %{
          "password" => "new valid password"
        })

      assert changeset.valid?
      assert get_change(changeset, :password) == "new valid password"
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "update_lecturer_password/3" do
    setup do
      %{lecturer: lecturer_fixture()}
    end

    test "validates password", %{lecturer: lecturer} do
      {:error, changeset} =
        Lecturers.update_lecturer_password(lecturer, valid_lecturer_password(), %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{lecturer: lecturer} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Lecturers.update_lecturer_password(lecturer, valid_lecturer_password(), %{password: too_long})

      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates current password", %{lecturer: lecturer} do
      {:error, changeset} =
        Lecturers.update_lecturer_password(lecturer, "invalid", %{password: valid_lecturer_password()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "updates the password", %{lecturer: lecturer} do
      {:ok, lecturer} =
        Lecturers.update_lecturer_password(lecturer, valid_lecturer_password(), %{
          password: "new valid password"
        })

      assert is_nil(lecturer.password)
      assert Lecturers.get_lecturer_by_email_and_password(lecturer.email, "new valid password")
    end

    test "deletes all tokens for the given lecturer", %{lecturer: lecturer} do
      _ = Lecturers.generate_lecturer_session_token(lecturer)

      {:ok, _} =
        Lecturers.update_lecturer_password(lecturer, valid_lecturer_password(), %{
          password: "new valid password"
        })

      refute Repo.get_by(LecturerToken, lecturer_id: lecturer.id)
    end
  end

  describe "generate_lecturer_session_token/1" do
    setup do
      %{lecturer: lecturer_fixture()}
    end

    test "generates a token", %{lecturer: lecturer} do
      token = Lecturers.generate_lecturer_session_token(lecturer)
      assert lecturer_token = Repo.get_by(LecturerToken, token: token)
      assert lecturer_token.context == "session"

      # Creating the same token for another lecturer should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%LecturerToken{
          token: lecturer_token.token,
          lecturer_id: lecturer_fixture().id,
          context: "session"
        })
      end
    end
  end

  describe "get_lecturer_by_session_token/1" do
    setup do
      lecturer = lecturer_fixture()
      token = Lecturers.generate_lecturer_session_token(lecturer)
      %{lecturer: lecturer, token: token}
    end

    test "returns lecturer by token", %{lecturer: lecturer, token: token} do
      assert session_lecturer = Lecturers.get_lecturer_by_session_token(token)
      assert session_lecturer.id == lecturer.id
    end

    test "does not return lecturer for invalid token" do
      refute Lecturers.get_lecturer_by_session_token("oops")
    end

    test "does not return lecturer for expired token", %{token: token} do
      {1, nil} = Repo.update_all(LecturerToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Lecturers.get_lecturer_by_session_token(token)
    end
  end

  describe "delete_session_token/1" do
    test "deletes the token" do
      lecturer = lecturer_fixture()
      token = Lecturers.generate_lecturer_session_token(lecturer)
      assert Lecturers.delete_session_token(token) == :ok
      refute Lecturers.get_lecturer_by_session_token(token)
    end
  end

  describe "deliver_lecturer_confirmation_instructions/2" do
    setup do
      %{lecturer: lecturer_fixture()}
    end

    test "sends token through notification", %{lecturer: lecturer} do
      token =
        extract_lecturer_token(fn url ->
          Lecturers.deliver_lecturer_confirmation_instructions(lecturer, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert lecturer_token = Repo.get_by(LecturerToken, token: :crypto.hash(:sha256, token))
      assert lecturer_token.lecturer_id == lecturer.id
      assert lecturer_token.sent_to == lecturer.email
      assert lecturer_token.context == "confirm"
    end
  end

  describe "confirm_lecturer/1" do
    setup do
      lecturer = lecturer_fixture()

      token =
        extract_lecturer_token(fn url ->
          Lecturers.deliver_lecturer_confirmation_instructions(lecturer, url)
        end)

      %{lecturer: lecturer, token: token}
    end

    test "confirms the email with a valid token", %{lecturer: lecturer, token: token} do
      assert {:ok, confirmed_lecturer} = Lecturers.confirm_lecturer(token)
      assert confirmed_lecturer.confirmed_at
      assert confirmed_lecturer.confirmed_at != lecturer.confirmed_at
      assert Repo.get!(Lecturer, lecturer.id).confirmed_at
      refute Repo.get_by(LecturerToken, lecturer_id: lecturer.id)
    end

    test "does not confirm with invalid token", %{lecturer: lecturer} do
      assert Lecturers.confirm_lecturer("oops") == :error
      refute Repo.get!(Lecturer, lecturer.id).confirmed_at
      assert Repo.get_by(LecturerToken, lecturer_id: lecturer.id)
    end

    test "does not confirm email if token expired", %{lecturer: lecturer, token: token} do
      {1, nil} = Repo.update_all(LecturerToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Lecturers.confirm_lecturer(token) == :error
      refute Repo.get!(Lecturer, lecturer.id).confirmed_at
      assert Repo.get_by(LecturerToken, lecturer_id: lecturer.id)
    end
  end

  describe "deliver_lecturer_reset_password_instructions/2" do
    setup do
      %{lecturer: lecturer_fixture()}
    end

    test "sends token through notification", %{lecturer: lecturer} do
      token =
        extract_lecturer_token(fn url ->
          Lecturers.deliver_lecturer_reset_password_instructions(lecturer, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert lecturer_token = Repo.get_by(LecturerToken, token: :crypto.hash(:sha256, token))
      assert lecturer_token.lecturer_id == lecturer.id
      assert lecturer_token.sent_to == lecturer.email
      assert lecturer_token.context == "reset_password"
    end
  end

  describe "get_lecturer_by_reset_password_token/1" do
    setup do
      lecturer = lecturer_fixture()

      token =
        extract_lecturer_token(fn url ->
          Lecturers.deliver_lecturer_reset_password_instructions(lecturer, url)
        end)

      %{lecturer: lecturer, token: token}
    end

    test "returns the lecturer with valid token", %{lecturer: %{id: id}, token: token} do
      assert %Lecturer{id: ^id} = Lecturers.get_lecturer_by_reset_password_token(token)
      assert Repo.get_by(LecturerToken, lecturer_id: id)
    end

    test "does not return the lecturer with invalid token", %{lecturer: lecturer} do
      refute Lecturers.get_lecturer_by_reset_password_token("oops")
      assert Repo.get_by(LecturerToken, lecturer_id: lecturer.id)
    end

    test "does not return the lecturer if token expired", %{lecturer: lecturer, token: token} do
      {1, nil} = Repo.update_all(LecturerToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Lecturers.get_lecturer_by_reset_password_token(token)
      assert Repo.get_by(LecturerToken, lecturer_id: lecturer.id)
    end
  end

  describe "reset_lecturer_password/2" do
    setup do
      %{lecturer: lecturer_fixture()}
    end

    test "validates password", %{lecturer: lecturer} do
      {:error, changeset} =
        Lecturers.reset_lecturer_password(lecturer, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{lecturer: lecturer} do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Lecturers.reset_lecturer_password(lecturer, %{password: too_long})
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "updates the password", %{lecturer: lecturer} do
      {:ok, updated_lecturer} = Lecturers.reset_lecturer_password(lecturer, %{password: "new valid password"})
      assert is_nil(updated_lecturer.password)
      assert Lecturers.get_lecturer_by_email_and_password(lecturer.email, "new valid password")
    end

    test "deletes all tokens for the given lecturer", %{lecturer: lecturer} do
      _ = Lecturers.generate_lecturer_session_token(lecturer)
      {:ok, _} = Lecturers.reset_lecturer_password(lecturer, %{password: "new valid password"})
      refute Repo.get_by(LecturerToken, lecturer_id: lecturer.id)
    end
  end

  describe "inspect/2" do
    test "does not include password" do
      refute inspect(%Lecturer{password: "123456"}) =~ "password: \"123456\""
    end
  end
end
