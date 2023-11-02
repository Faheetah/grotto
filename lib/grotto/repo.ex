defmodule Grotto.Repo do
  use Ecto.Repo,
    otp_app: :grotto,
    adapter: Ecto.Adapters.Postgres
end
