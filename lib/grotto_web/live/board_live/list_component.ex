defmodule GrottoWeb.BoardLive.ListComponent do
  use GrottoWeb, :live_component

  alias Grotto.Lists
  alias Grotto.Lists.List

  @impl true
  def render(%{list: list} = assigns) do
    ~H"""
    <div class="p-2 mb-auto bg-neutral-200 space-y-2 w-72 rounded shadow-sm shadow-neutral-400 flex-shrink-0">
      <div class="p-2 font-bold text-sm">
        <%= list.name %>
      </div>
      <%= for card <- list.cards do %>
        <div
          id={"card-#{list.id}-#{card.id}"}
          draggable="true"
          phx-keydown="deleteCard(event)"
          phx-hook="Drag"
          phx-value-card={card.id}
          class="text-sm"
        >
          <div class="p-2 bg-white rounded shadow" phx-value-card={card.id}>
            <%= card.name %>
          </div>
        </div>
      <% end %>

      <div>
        <.link onclick={"document.getElementById('card-input-#{list.id}').style.display = 'block'; document.getElementById('card-input-field-#{list.id}').focus(); this.hidden = true;"}>
          <div phx-hook="Drag" id={"new-button-#{list.id}"} phx-value-card="last" phx-value-list={list.id} class="p-2 text-sm font-medium w-full hover:bg-neutral-300">
            <span class="text-xl">+</span> Add a card
          </div>
        </.link>

        <div id={"card-input-#{list.id}"} class="hidden">
          <.form for={%{}} :let={f} phx-submit="new_card" phx-value-list_id={list.id}>
            <.input field={f[:name]} phx-blur="new_card" phx-value-list_id={list.id} type="text" id={"card-input-field-#{list.id}"} />
          </.form>
        </div>
      </div>
    </div>
    """
  end
end
