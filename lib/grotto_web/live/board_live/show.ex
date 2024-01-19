defmodule GrottoWeb.BoardLive.Show do
  use GrottoWeb, :live_view

  alias Grotto.Boards
  alias Grotto.Lists

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {board_id, _} = Integer.parse(id)

    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:board, Boards.get_board!(board_id))
    |> apply_action(socket.assigns.live_action)
    |> then(fn s -> {:noreply, s} end)
  end

  defp apply_action(socket, :new_list), do: assign(socket, :list, %Grotto.Lists.List{})
  defp apply_action(socket, _), do: socket

  @impl true
  def handle_event("new_card", %{"list_id" => list_id} = params, socket) do
    card = Grotto.Lists.create_card(Map.put(params, "name", params["value"]))

    socket.assigns.board.lists
    |> Enum.reduce([], fn l, acc ->
      if l.id == list_id do
        [[card | l] | acc]
      else
        [l | acc]
      end
    end)
    |> Enum.reverse()

    board = Grotto.Boards.get_board!(socket.assigns.board.id)
    # {:noreply, assign(socket, :board, Map.put(socket.assigns.board, :lists, lists))}
    {:noreply, assign(socket, :board, board)}
  end

  def handle_event("change_rank", %{"list" => list_id, "sourceCard" => card_id, "targetCard" => rank}, socket) do
    {list_id, _} = Integer.parse(list_id)
    {card_id, _} = Integer.parse(card_id)
    {rank, _} = Integer.parse(rank)

    list = Lists.get_list!(list_id)
    board = Boards.get_board!(list.board_id)
    # @todo really horrible performance, fix later
    {:noreply, assign(socket, :board, board)}
  end

  def handle_event("reorder_card", %{"sourceCard" => source_card, "targetCard" => "last", "list" => list}, socket) do
    {source_card_id, _} = Integer.parse(source_card)
    {list_id, _} = Integer.parse(list)
    source_card = Lists.get_card!(source_card_id)

    last_card =
      socket.assigns.board.lists
      |> Enum.find(fn l -> l.id == list_id end)
      |> Map.get(:cards)
      |> List.last()

    case last_card do
      nil -> Lists.reorder_card(source_card_id, nil, list)
      target_card -> Lists.reorder_card(source_card_id, target_card.id, list)
    end

    board = Boards.get_board!(socket.assigns.board.id)
    {:noreply, assign(socket, :board, board)}
  end

  def handle_event("reorder_card", %{"sourceCard" => source_card, "targetCard" => target_card}, socket) do
    {source_card_id, _} = Integer.parse(source_card)
    {target_card_id, _} = Integer.parse(target_card)

    Lists.reorder_card(source_card_id, target_card_id)

    board = Boards.get_board!(socket.assigns.board.id)
    {:noreply, assign(socket, :board, board)}
  end

  def handle_event("archive_card", %{"card" => card}, socket) do
    # @todo this needs to reorder cards, then we can delete with no fkey
    Lists.get_card!(card)
    |> Lists.delete_card()

    board = Boards.get_board!(socket.assigns.board.id)
    {:noreply, assign(socket, :board, board)}
  end

  defp page_title(:edit), do: "Edit Board"
  defp page_title(:new_list), do: "New List"
  defp page_title(_), do: "Show Board"
end
