defmodule GrottoWeb.BoardLive.Archived do
  use GrottoWeb, :live_view

  alias Grotto.Boards
  alias Grotto.Cards

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id} = _params, _, socket) do
    {board_id, _} = Integer.parse(id)

    socket
    |> assign(:page_title, "Archived cards")
    |> assign(:board, Boards.get_board!(id))
    |> assign(:cards, Cards.list_archived_cards!(board_id))
    |> then(fn s -> {:noreply, s} end)
  end

  @impl true
  def handle_event("archive_card", %{"card" => card}, socket) do
    Cards.get_card!(card)
    |> Cards.unarchive_card()

    cards = Cards.list_archived_cards!(socket.assigns.board.id)
    {:noreply, assign(socket, :cards, cards)}
  end
end
