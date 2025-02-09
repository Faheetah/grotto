defmodule Grotto.Lists do
  @moduledoc """
  The Lists context.
  """

  import Ecto.Query, warn: false
  alias Grotto.Repo

  alias Grotto.Boards
  alias Grotto.Lists.List
  alias Grotto.Cards.Card

  @doc """
  Returns the list of lists.

  ## Examples

      iex> list_lists()
      [%List{}, ...]

  """
  def list_lists_for_board(board_id) do
    List
    |> where([l], l.board_id == ^board_id)
    |> order_by([l], l.rank)
    |> Repo.all()
    |> Enum.map(fn list -> Map.put(list, :cards, Boards.get_cards(list)) end)
  end

  @doc """
  Gets a single list.

  Raises `Ecto.NoResultsError` if the List does not exist.

  ## Examples

      iex> get_list!(123)
      %List{}

      iex> get_list!(456)
      ** (Ecto.NoResultsError)

  """
  def get_list!(id) do
    list = Repo.get!(List, id)
    Map.put(list, :cards, Boards.get_cards(list))
  end

  @doc """
  Creates a list.

  ## Examples

      iex> create_list(%{field: value})
      {:ok, %List{}}

      iex> create_list(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_list(attrs \\ %{}) do
    %List{}
    |> List.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a list.

  ## Examples

      iex> update_list(list, %{field: new_value})
      {:ok, %List{}}

      iex> update_list(list, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_list(%List{} = list, attrs) do
    list
    |> List.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a list.

  ## Examples

      iex> delete_list(list)
      {:ok, %List{}}

      iex> delete_list(list)
      {:error, %Ecto.Changeset{}}

  """
  def delete_list(%List{} = list) do
    Repo.delete(list)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking list changes.

  ## Examples

      iex> change_list(list)
      %Ecto.Changeset{data: %List{}}

  """
  def change_list(%List{} = list, attrs \\ %{}) do
    List.changeset(list, attrs)
  end

  @doc """
  Iterates through a list, asserting all cards are ordered, and ordering if not.
  Fixes issues when parent_card_id is improperly set.

  WARNING: this may incorrectly order cards!
  """
  def fix_list(%List{} = list) do
    list
    |> Map.put(:cards, Boards.get_cards(list))
    |> Map.get(:cards)
    |> Enum.reduce(nil, fn card, parent_card_id ->
        card
        |> Card.changeset(%{"parent_card_id" => parent_card_id})
        |> Repo.update!()

        card.id
      end)
  end
end
