defmodule Grotto.Repo.Migrations.AddSoftDeletesToCards do
  use Ecto.Migration

  def change do
    alter table("cards") do
      add :deleted_at, :timestamp
    end
  end
end
