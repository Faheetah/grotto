defmodule Grotto.Cards.Card do
  use Ecto.Schema
  import Ecto.Changeset

  alias Grotto.Lists.List

  @derive [Poison.Encoder]

  schema "cards" do
    field :name, :string
    field :description, :string
    field :color, :string
    field :due_date, :utc_datetime
    field :deleted_at, :utc_datetime
    belongs_to :card, __MODULE__, foreign_key: :parent_card_id
    belongs_to :list, List

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(nil, _), do: nil
  def changeset(card, attrs) do
    card
    |> cast(attrs, [:name, :description, :color, :list_id, :parent_card_id, :deleted_at, :due_date])
    |> validate_required([:name, :list_id])
  end
end
