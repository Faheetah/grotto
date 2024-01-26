defmodule GrottoWeb.BoardLive.Index do
  use GrottoWeb, :live_view

  alias Grotto.Boards
  alias Grotto.Boards.Board

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :boards, Boards.list_boards())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :export, %{"id" => id}) do
    export_data = Grotto.Importer.export(id)

    socket
    |> assign(:page_title, "Export Board")
    |> assign(:board, Boards.get_board!(id))
    |> assign(:export, export_data)
  end

  defp apply_action(socket, :import, _params) do
    socket
    |> assign(:page_title, "Import Board")
  end
  defp apply_action(socket, :edit, %{"id" => id}) do
    {board_id, _} = Integer.parse(id)
    socket
    |> assign(:page_title, "Edit Board")
    |> assign(:board, Boards.get_board!(board_id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Board")
    |> assign(:board, %Board{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Boards")
    |> assign(:board, nil)
  end

  @impl true
  def handle_info({GrottoWeb.BoardLive.FormComponent, {:saved, board}}, socket) do
    {:noreply, stream_insert(socket, :boards, board)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    board = Boards.get_board!(id)
    {:ok, _} = Boards.delete_board(board)

    # @todo need to implement streams into the main template
    # this was based off of <.table> originally that supports streams
    {:noreply, stream_delete(socket, :boards, board)}
  end

  @impl true
  def handle_event("import-board", %{"data" => data}, socket) do
    board = Grotto.Importer.import(data)

    {
      :noreply,
      socket
      |> put_flash(:info, "Board #{board.name} imported successfully")
      |> push_redirect(to: "/boards/#{board.id}")
    }
  end
end
