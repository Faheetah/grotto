defmodule GrottoWeb.BoardLive.CardComponent do
  use GrottoWeb, :live_component

  alias Grotto.Lists
  alias Grotto.Lists.List

  @impl true
  def render(%{card: card} = assigns) do
    ~H"""
    <div>
      <div class="text-2xl">
        <%= card.name %>
      </div>
      <div class="text-md">
        <%= card.description %>
      </div>
    </div>
    """
  end
end
