defmodule GrottoWeb.BoardLive.Show do
  use GrottoWeb, :live_view

  alias Grotto.Boards
  alias Grotto.Lists
  alias Grotto.Cards

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :tz_offset, Map.get(socket.private.connect_params, "tz_offset"))}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _, socket) do
    {board_id, _} = Integer.parse(id)
    overdue_cards = Cards.list_overdue_cards!(board_id)

    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:board, Boards.get_board!(board_id))
    |> assign(:lists, Lists.list_lists_for_board(board_id))
    |> assign(:overdue_cards, overdue_cards)
    |> apply_action(socket.assigns.live_action, params)
    |> then(fn s -> {:noreply, s} end)
  end

  defp apply_action(socket, :show_card, %{"card_id" => card_id}) do
    card = Cards.get_card!(card_id)
    socket
    |> assign(:card, card)
  end
  defp apply_action(socket, _, _), do: socket

  @impl true
  def handle_event("new_card", %{"value" => ""}, socket), do: {:noreply, socket}

  @impl true
  def handle_event("new_card", %{"list_id" => list_id} = params, socket) do
    card = Grotto.Cards.create_card(Map.put(params, "name", params["value"]))

    socket.assigns.lists
    |> Enum.reduce([], fn l, acc ->
      if l.id == list_id do
        [[card | l] | acc]
      else
        [l | acc]
      end
    end)
    |> Enum.reverse()

    lists = Grotto.Lists.list_lists_for_board(socket.assigns.board.id)
    {:noreply, assign(socket, :lists, lists)}
  end

  @impl true
  def handle_event("new_list", %{"value" => ""}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("new_list", params, socket) do
    {:ok, _list} = Grotto.Lists.create_list(Map.put(params, "name", params["value"]))

    # this is ugly but we can't update/3 because of board
    lists = Grotto.Lists.list_lists_for_board(socket.assigns.board.id)
    {:noreply, assign(socket, :lists, lists)}
  end

  @impl true
  def handle_event("update_card_description", %{"card_id" => card_id, "description" => description}, socket) do
    {:ok, card} = Cards.update_card_description(Cards.get_card!(card_id), description)

    {:noreply, assign(socket, :card, card)}
  end

  @impl true
  def handle_event("reorder_card", %{"sourceCard" => source_card, "targetCard" => "last", "list" => list}, socket) do
    {source_card_id, _} = Integer.parse(source_card)
    {list_id, _} = Integer.parse(list)

    last_card =
      socket.assigns.lists
      |> Enum.find(fn l -> l.id == list_id end)
      |> Map.get(:cards)
      |> List.last()

    case last_card do
      nil -> Cards.reorder_card(source_card_id, nil, list)
      target_card -> Cards.reorder_card(source_card_id, target_card.id, list)
    end

    lists = Lists.list_lists_for_board(socket.assigns.board.id)
    {:noreply, assign(socket, :lists, lists)}
  end

  @impl true
  def handle_event("reorder_card", %{"sourceCard" => source_card, "targetCard" => target_card}, socket) do
    {source_card_id, _} = Integer.parse(source_card)
    {target_card_id, _} = Integer.parse(target_card)

    Cards.reorder_card(source_card_id, target_card_id)

    lists = Lists.list_lists_for_board(socket.assigns.board.id)
    {:noreply, assign(socket, :lists, lists)}
  end

  @impl true
  def handle_event("update_due_date", %{"card_id" => card_id, "value" => due_date}, socket) do
    {:ok, card} = Cards.update_due_date(Cards.get_card!(card_id), due_date)

    {:noreply, assign(socket, :card, card)}
  end

  @impl true
  def handle_event("set_color", %{"card" => card, "color" => color}, socket) do
    Cards.get_card!(card)
    |> Cards.set_color(color)

    lists = Lists.list_lists_for_board(socket.assigns.board.id)
    {:noreply, assign(socket, :lists, lists)}
  end

  @impl true
  def handle_event("fix_list", %{"list_id" => list_id}, socket) do
    list_id
    |> Lists.get_list!
    |> Lists.fix_list

    lists = Lists.list_lists_for_board(socket.assigns.board.id)
    {:noreply, assign(socket, :lists, lists)}
  end

  @impl true
  def handle_event("rename_card", %{"value" => ""}, socket), do: {:noeply, socket}
  def handle_event("rename_card", %{"card_id" => id, "value" => name}, socket) do
    card = Cards.get_card!(id)
    {:ok, card} = Cards.update_card_name(card,  name)

    {:noreply, assign(socket, :card, card)}
  end

  @impl true
  def handle_event("archive_card", %{"card" => "last"}, socket), do: {:noreply, socket}
  def handle_event("archive_card", %{"card" => card}, socket) do
    # @todo this needs to reorder cards, then we can delete with no fkey
    Cards.get_card!(card)
    |> Cards.archive_card()

    overdue_cards = Cards.list_overdue_cards!(socket.assigns.board.id)

    lists = Lists.list_lists_for_board(socket.assigns.board.id)

    {
      :noreply,
      socket
      |> assign(:lists, lists)
      |> assign(:overdue_cards, overdue_cards)
    }
  end

  @impl true
  def handle_event("delete_card", %{"id" => card}, socket) do
    Cards.get_card!(card)
    |> Cards.delete_card()

    lists = Lists.list_lists_for_board(socket.assigns.board.id)
    {
      :noreply,
      socket
      |> assign(:lists, lists)
      |> push_redirect(to: "/boards/#{socket.assigns.board.id}")
    }
  end

  @impl true
  def handle_event("rename_list", %{"value" => ""}, socket), do: {:noreply, socket}
  def handle_event("rename_list", %{"list_id" => id, "value" => name}, socket) do
    list = Lists.get_list!(id)
    {:ok, _} = Lists.update_list(list, %{"name" => name})

    lists = Lists.list_lists_for_board(socket.assigns.board.id)
    {:noreply, assign(socket, :lists, lists)}
  end

  @impl true
  def handle_event("rerank_list", %{"list_id" => list_id, "value" => rank}, socket) do
    Lists.get_list!(list_id)
    |> Lists.update_list(%{"rank" => rank})

    lists = Lists.list_lists_for_board(socket.assigns.board.id)
    {:noreply, assign(socket, :lists, lists)}
  end

  @impl true
  def handle_event("delete_list", %{"list_id" => list_id}, socket) do
    Lists.get_list!(list_id)
    |> Lists.delete_list()

    lists = Lists.list_lists_for_board(socket.assigns.board.id)
    {:noreply, assign(socket, :lists, lists)}
  end

  @impl true
  def handle_event("update_board", %{"value" => ""}, socket), do: {:noreply, socket}

  @impl true
  def handle_event("update_board", %{"board_id" => id, "value" => name}, socket) do
    board = Boards.get_board!(id)
    {:ok, board} = Boards.update_board(board, %{"name" => name})

    {:noreply, assign(socket, :board, board)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    board = Boards.get_board!(id)
    {:ok, _} = Boards.delete_board(board)

    {:noreply, push_redirect(socket, to: "/boards")}
  end

  defp page_title(:edit), do: "Edit Board"
  defp page_title(:new_list), do: "New List"
  defp page_title(_), do: "Show Board"
end
