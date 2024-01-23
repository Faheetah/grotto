defmodule Grotto.Cards do
  @moduledoc """
  The Cards context.
  """

  import Ecto.Query, warn: false
  alias Grotto.Repo

  alias Ecto.Multi

  alias Grotto.Lists
  alias Grotto.Cards.Card

  @doc """
  Creates a card.
  """
  def create_card(attrs \\ %{}) do
    {list_id, _} = Integer.parse(attrs["list_id"])
    list = Lists.get_list!(list_id)
    cards = Enum.reverse(list.cards)
    parent_card_id = get_parent_card(cards)

    %Card{}
    |> Card.changeset(Map.put(attrs, "parent_card_id", parent_card_id))
    |> Repo.insert()
  end

  def update_card_name(%Card{} = card, name) do
    Card.changeset(card, %{"name" => name})
    |> Repo.update()
  end

  def update_card_description(%Card{} = card, description) do
    Card.changeset(card, %{"description" => description})
    |> Repo.update()
  end

  defp get_parent_card([]), do: nil
  defp get_parent_card([card | _rest]), do: card.id

  def get_card!(card_id) do
    Repo.get!(Card, card_id)
  end

  def reorder_card(id, id, _list), do: nil
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

  def reorder_card(id, id), do: nil
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
end
