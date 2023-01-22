import Ecto.Query
import Ecto.Changeset
alias Ecto.Adapters.Postgres
alias Attendance.Repo
alias Attendance.Accounts.Admin
alias Attendance.Lecturers.Lecturer
alias Attendance.Catalog.{Session, Program, Class, Semester, Courses}

alias Attendance.{Accounts, Catalog, Lecturers, Timetables}

alias AttendanceApi.Resolvers.Lecturer
alias AttendanceApi.Resolvers.Catalog

# fly ssh console -C "app/bin/attendance remote"
# Attendance.GlobalSetup.multiply_seeder()
