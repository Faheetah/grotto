defmodule Grotto.Repo.Migrations.AddColorToCards do
  use Ecto.Migration

  def change do
    alter table("cards") do
      add :color, :text
    end
  end
end
