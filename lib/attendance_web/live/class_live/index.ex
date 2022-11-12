defmodule AttendanceWeb.ClassLive.Index do
  use AttendanceWeb, :live_view

  alias Attendance.Catalog
  alias Attendance.Catalog.Class

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :classes, list_classes())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Class")
    |> assign(:class, Catalog.get_class!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Class")
    |> assign(:class, %Class{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Classes")
    |> assign(:class, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    class = Catalog.get_class!(id)
    {:ok, _} = Catalog.delete_class(class)

    {:noreply, assign(socket, :classes, list_classes())}
  end

  defp list_classes do
    Catalog.list_classes()
  end
end
