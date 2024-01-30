defmodule Grotto.Importer do
  import Ecto.Query, warn: false
  alias Grotto.Repo

  alias Grotto.Boards
  alias Grotto.Boards.Board
  alias Grotto.Lists.List
  alias Grotto.Cards.Card

  def export(board_id) do
    board_id
    |> Boards.get_board!()
    |> Poison.encode!()
  end

  def import(data) do
    data
    |> Poison.decode!(as: %Board{lists: [%List{cards: [%Card{}]}]})
    |> insert_board()
  end

  defp insert_board(data) do
    board =
      %Board{}
      |> Board.changeset(%{"name" => data.name})
      |> Repo.insert!()

    insert_lists(board, data.lists)

    board
  end

  defp insert_lists(board, lists) do
    Enum.each(lists, fn list ->
      Repo.insert!(List.changeset(%List{}, %{"name" => list.name, "board_id" => board.id}))
      |> insert_cards(list.cards)
    end)
  end

  # this will not add the cards ordered, but they may be incidentally ordered from export
  defp insert_cards(list, cards) do
    Enum.reduce(cards, nil, fn card, parent ->
      Repo.insert!(Card.changeset(%Card{}, %{"name" => card.name, "description" => card.description, "list_id" => list.id, "parent_card_id" => parent}))
      |> Map.get(:id)
    end)
  end
end
