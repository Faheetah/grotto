defmodule GrottoWeb.BoardLive.Show do
  use GrottoWeb, :live_view

  alias Grotto.Boards
  alias Grotto.Lists.List

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:board, Boards.get_board!(id))
    |> apply_action(socket.assigns.live_action)
    |> then(fn s -> {:noreply, s} end)
  end

  defp apply_action(socket, :new_list), do: assign(socket, :list, %List{})
  defp apply_action(socket, _), do: socket

  defp page_title(:show), do: "Show Board"
  defp page_title(:edit), do: "Edit Board"
  defp page_title(:new_list), do: "New List"
end
