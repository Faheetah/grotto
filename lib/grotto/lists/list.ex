defmodule Grotto.Lists.List do
  use Ecto.Schema
  import Ecto.Changeset

  alias Grotto.Boards.Board
  alias Grotto.Cards.Card

  @derive [Poison.Encoder]

  schema "lists" do
    field :name, :string
    field :rank, :integer
    belongs_to :board, Board
    has_many :cards, Card

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(list, attrs) do
    list
    |> cast(attrs, [:name, :rank, :board_id])
    |> validate_required([:name, :board_id])
  end
end
