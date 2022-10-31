defmodule AttendanceWeb.AdminRegistrationController do
  use AttendanceWeb, :controller

  alias Attendance.Accounts
  alias Attendance.Accounts.Admin
  alias AttendanceWeb.AdminAuth

  def new(conn, _params) do
    changeset = Accounts.change_admin_registration(%Admin{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"admin" => admin_params}) do
    case Accounts.register_admin(admin_params) do
      {:ok, admin} ->
        {:ok, _} =
          Accounts.deliver_admin_confirmation_instructions(
            admin,
            &Routes.admin_confirmation_url(conn, :edit, &1)
          )

        conn
        |> put_flash(:info, "Admin created successfully.")
        |> AdminAuth.log_in_admin(admin)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
