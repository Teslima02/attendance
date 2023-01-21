defmodule AttendanceApi.Resolvers.Catalog do
  alias Attendance.Catalog

  def current_session(_arg, %{
        context: %{current_lecturer: _current_lecturer}
      }) do
    case Attendance.Catalog.get_current_session!() do
      nil ->
        {:error, "Session is not available"}

      session ->
        {:ok, session}
    end
  end

  def list_programs(%{input: input_params}, %{
        context: %{current_lecturer: _current_lecturer}
      }) do
    with {:ok, page} <- Attendance.Catalog.paginate_programs(input_params) do
      {:ok, page}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error,
         message: "An error occurred while getting programs",
         details: Attendance.Errors.GraphqlErrors.transform_errors(changeset)}
    end
  end

  def get_current_semester(%{input: input_params}, _) do
    case Attendance.Catalog.get_current_semester!(input_params) do
      nil ->
        {:error, "Semester is not available"}

      semester ->
        {:ok, semester}
    end
  end

  def list_classes(%{input: input_params}, %{
        context: %{current_lecturer: _current_lecturer}
      }) do
    with {:ok, class} <- Attendance.Catalog.paginate_classes(input_params) do
      {:ok, class}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error,
         message: "An error occurred while getting programs",
         details: Attendance.Errors.GraphqlErrors.transform_errors(changeset)}
    end
  end
end
