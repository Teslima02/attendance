defmodule AttendanceApi.Resolvers.Catalog do
  alias Attendance.Catalog

  def current_session(_arg, %{
        context: %{current_lecturer: current_lecturer}
      }) do
    case Attendance.Catalog.get_current_session!() do
      nil ->
        {:error, "Session is not available"}

      session ->
        {:ok, session}
    end
  end

  def list_programs(%{input: input_params}, %{
        context: %{current_lecturer: current_lecturer}
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
end
