import Ecto.Query
import Ecto.Changeset
alias Ecto.Adapters.Postgres
alias Attendance.Repo
alias Attendance.Accounts.Admin
alias Attendance.Lecturers.Lecturer
alias Attendance.Catalog.{Session, Program, Class, Semester, Courses}

alias Attendance.{Accounts, Catalog, Lecturers}
