defmodule Grotto.Lists do
  @moduledoc """
  The Lists context.
  """

  import Ecto.Query, warn: false
  alias Grotto.Repo

  alias Ecto.Multi

  alias Grotto.Lists.List
  alias Grotto.Lists.Card

  @doc """
  Returns the list of lists.

  ## Examples

      iex> list_lists()
      [%List{}, ...]

  """
  def list_lists do
    Repo.all(List)
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
    List
    |> preload([:cards])
    |> Repo.get!(id)
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

  def create_card(attrs \\ %{}) do
    {list_id, _} = Integer.parse(attrs["list_id"])
    list = get_list!(list_id)
    cards = Enum.reverse(list.cards)
    parent_card_id = get_parent_card(cards)

    %Card{}
    |> Card.changeset(Map.put(attrs, "parent_card_id", parent_card_id))
    |> Repo.insert()
  end

  defp get_parent_card([]), do: nil
  defp get_parent_card([card | _rest]), do: card.id

  def get_card!(card_id) do
    Repo.get!(Card, card_id)
  end

  def reorder_card(id, id), do: nil

  def reorder_card(source_card_id, nil, list_id) do
    source_card = get_card!(source_card_id)
    source_card_child = get_child_card(source_card.id)

    changes = [
      {
        :source_card_child_changeset,
        Card.changeset(source_card_child, %{"parent_card_id" => source_card.parent_card_id})
      },
      {
        :source_card_changeset,
        Card.changeset(source_card, %{"parent_card_id" => nil, "list_id" => list_id})
      }
    ]

    Enum.reduce(changes, Multi.new(), fn {name, change}, multi ->
      if change != nil do
        Multi.update(multi, name, change)
      else
        multi
      end
    end)
    |> Repo.transaction()
  end

  def reorder_card(source_card_id, target_card_id, list_id) do
    source_card = get_card!(source_card_id)
    source_card_child = get_child_card(source_card.id)

    changes = [
      {
        :source_card_child_changeset,
        Card.changeset(source_card_child, %{"parent_card_id" => source_card.parent_card_id})
      },
      {
        :source_card_changeset,
        Card.changeset(source_card, %{"parent_card_id" => target_card_id, "list_id" => list_id})
      }
    ]

    Enum.reduce(changes, Multi.new(), fn {name, change}, multi ->
      if change != nil do
        Multi.update(multi, name, change)
      else
        multi
      end
    end)
    |> Repo.transaction()
  end
  def reorder_card(source_card_id, target_card_id) do
    source_card = get_card!(source_card_id)
    target_card = get_card!(target_card_id)

    source_card_child = get_child_card(source_card.id)
    target_card_child = get_child_card(target_card.id)

    # take the target card, update its parent to the source card
    # take the source card child, update parent to source card old parent
    # take the source card, update its parent id to target card parent
    # unless source card is moving down one slot, then they need to basically swap
    changes = [
      {
        :target_card_changeset,
        if source_card.id == target_card.parent_card_id do
          Card.changeset(target_card, %{"parent_card_id" => source_card.parent_card_id})
        else
          Card.changeset(target_card, %{"parent_card_id" => source_card.id})
        end
      },
      {
        :source_card_child_changeset,
        Card.changeset(source_card_child, %{"parent_card_id" => source_card.parent_card_id})
      },
      {
        :target_card_child_changeset,
        if source_card.id == target_card.parent_card_id do
          Card.changeset(target_card_child, %{"parent_card_id" => source_card.id})
        end
      },
      {
        :source_card_changeset,
        if source_card.id == target_card.parent_card_id do
          Card.changeset(source_card, %{"parent_card_id" => target_card.id, "list_id" => target_card.list_id})
        else
          Card.changeset(source_card, %{"parent_card_id" => target_card.parent_card_id, "list_id" => target_card.list_id})
        end
      }
    ]

    # we reduce in case there are nil parents/children, as nil does not need to get updated
    Enum.reduce(changes, Multi.new(), fn {name, change}, multi ->
      if change != nil do
        Multi.update(multi, name, change)
      else
        multi
      end
    end)
    |> Repo.transaction()
  end

  defp change_card(%Card{} = card, attrs \\ %{}) do
    Card.changeset(card, attrs)
  end

  defp get_child_card(card_id) do
    Repo.one(from c in Card, where: c.parent_card_id == ^card_id)
  end

  def delete_card(%Card{} = card) do
    child = get_child_card(card.id)

    if child do
      Multi.new()
      |> Multi.update(:update_child_card, Card.changeset(child, %{"parent_card_id" => card.parent_card_id}))
      |> Multi.delete(:delete_card, card)
      |> Repo.transaction()
    else
      Repo.delete(card)
    end
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
end
