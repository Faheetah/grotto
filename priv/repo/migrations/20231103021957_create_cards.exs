defmodule Grotto.Repo.Migrations.CreateCards do
  use Ecto.Migration

  def change do
    create table(:cards) do
      add :name, :string
      add :parent_card_id, references(:cards, on_delete: :nothing)
      add :list_id, references(:lists, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:cards, [:list_id])
    create index(:cards, [:parent_card_id])
  end
end
