defmodule Grotto.Boards do
  @moduledoc """
  The Boards context.
  """

  import Ecto.Query, warn: false
  alias Grotto.Repo

  alias Grotto.Boards.Board
  alias Grotto.Cards.Card

  @doc """
  Returns the list of boards.

  ## Examples

      iex> list_boards()
      [%Board{}, ...]

  """
  def list_boards do
    Repo.all(Board)
  end

  @doc """
  Gets a single board.

  Raises `Ecto.NoResultsError` if the Board does not exist.

  ## Examples

      iex> get_board!(123)
      %Board{}

      iex> get_board!(456)
      ** (Ecto.NoResultsError)

  """
  def get_board!(id) do
    board =
      Repo.get!(Board, id)
      |> Repo.preload(:lists)

    Map.put(board, :lists, Enum.map(board.lists, &get_cards/1))
  end

  @card_tree """
    SELECT id, parent_card_id, ARRAY[id] AS path
    FROM cards
    WHERE parent_card_id IS NULL
    UNION ALL
    SELECT c.id, c.parent_card_id, ct.path || c.id
    FROM cards AS c
    JOIN card_tree AS ct ON ct.id = c.parent_card_id
    """

  def get_cards(list) do
    cards =
      Card
      |> recursive_ctes(true)
      |> with_cte("card_tree", as: fragment(@card_tree))
      |> join(:inner, [c], ct in "card_tree", on: ct.id == c.id)
      |> where([c], c.list_id == ^list.id and is_nil c.deleted_at)
      |> select([c, ct], %{c | id: c.id})
      |> order_by([c, ct], ct.path)
      |> Repo.all()

    Map.put(list, :cards, cards)
  end

  @doc """
  Creates a board.

  ## Examples

      iex> create_board(%{field: value})
      {:ok, %Board{}}

      iex> create_board(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_board(attrs \\ %{}) do
    %Board{}
    |> Board.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a board.

  ## Examples

      iex> update_board(board, %{field: new_value})
      {:ok, %Board{}}

      iex> update_board(board, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_board(%Board{} = board, attrs) do
    board
    |> Board.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a board.

  ## Examples

      iex> delete_board(board)
      {:ok, %Board{}}

      iex> delete_board(board)
      {:error, %Ecto.Changeset{}}

  """
  def delete_board(%Board{} = board) do
    Repo.delete(board)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking board changes.

  ## Examples

      iex> change_board(board)
      %Ecto.Changeset{data: %Board{}}

  """
  def change_board(%Board{} = board, attrs \\ %{}) do
    Board.changeset(board, attrs)
  end
end
