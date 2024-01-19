defmodule Grotto.Cards.Card do
  use Ecto.Schema
  import Ecto.Changeset

  alias Grotto.Lists.List

  schema "cards" do
    field :name, :string
    field :description, :string
    belongs_to :card, Card, foreign_key: :parent_card_id
    belongs_to :list, List

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(nil, _), do: nil
  def changeset(card, attrs) do
    card
    |> cast(attrs, [:name, :description, :list_id, :parent_card_id])
    |> validate_required([:name, :list_id])
  end
end
