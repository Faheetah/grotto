defmodule Grotto.Boards.Board do
  use Ecto.Schema
  import Ecto.Changeset

  alias Grotto.Lists.List

  @derive [Poison.Encoder]

  schema "boards" do
    field :name, :string
    has_many :lists, List

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(board, attrs) do
    board
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
