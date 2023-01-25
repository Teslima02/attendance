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

# fly.io db connection string
# postgres://{username}:{password}@{hostname}:{port}/{database}?options
# postgres://sams:z94TxXKDwgMuPkp@top2.nearest.of.sams-db.internal:5432/sams?sslmode=disable

# flyctl proxy 15433 -a sams-db

# Postgres cluster sams created
#   Username:    postgres
#   Password:    pTCd7H6QNuVFDNd
#   Hostname:    sams.internal
#   Proxy port:  5432
#   Postgres port:  5433
#   Connection string: postgres://postgres:pTCd7H6QNuVFDNd@sams.internal:5432

# Save your credentials in a secure place -- you won't be able to see them again!

# Connect to postgres
# Any app within the Teslim Abdulafeez organization can connect to this Postgres using the following connection string:

# Now that you've set up Postgres, here's what you need to understand: https://fly.io/docs/postgres/getting-started/what-you-should-know/
