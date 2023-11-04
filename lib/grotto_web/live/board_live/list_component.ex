defmodule GrottoWeb.BoardLive.ListComponent do
  use GrottoWeb, :live_component

  alias Grotto.Lists
  alias Grotto.Lists.List

  @impl true
  def render(%{list: list} = assigns) do
    ~H"""
    <div class="p-2 bg-neutral-200 space-y-2">
      <div class="px-2 font-medium text-sm">
        <%= list.name %>
      </div>
      <%= for card <- list.cards do %>
        <div
          id={"card-#{list.id}-#{card.id}-#{card.parent_card_id}"}
          draggable="true"
          ondragstart="dragStart(event)"
          phx-hook="Drag"
          phx-value-card={card.id}
          class="p-2 bg-white text-sm"
        >
          <%= card.name %> (parent_card_id: <%= card.parent_card_id %> id:<%= card.id %>)
        </div>
      <% end %>

      <div>
        <.link onclick={"document.getElementById('card-input-#{list.id}').style.display = 'block'; document.getElementById('card-input-field-#{list.id}').focus(); this.hidden = true;"}>
          <div class="p-2 text-sm w-full hover:bg-neutral-300">
            + add card
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
