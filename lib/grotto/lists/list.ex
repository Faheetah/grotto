defmodule Grotto.Lists.List do
  use Ecto.Schema
  import Ecto.Changeset

  alias Grotto.Boards.Board

  schema "lists" do
    field :name, :string
    belongs_to :board, Board

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(list, attrs) do
    list
    |> cast(attrs, [:name, :board_id])
    |> validate_required([:name, :board_id])
  end
end
