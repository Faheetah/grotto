defmodule Grotto.Repo.Migrations.AddOrderToLists do
  use Ecto.Migration

  def change do
    alter table("lists") do
      add :rank, :integer
    end
  end
end
