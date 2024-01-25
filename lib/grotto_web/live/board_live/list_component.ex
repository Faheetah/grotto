defmodule GrottoWeb.BoardLive.ListComponent do
  use GrottoWeb, :live_component

  @impl true
  def render(%{list: list} = assigns) do
    ~H"""
    <div class="p-2 mb-auto bg-neutral-200 space-y-2 w-72 rounded shadow-sm shadow-neutral-400 flex-shrink-0">
      <.inline_input class="h-8 w-full my-1" action="rename_list" id={@list.id} phx-value-list_id={@list.id}>
        <div class="p-2 flex font-bold text-sm">
          <div class="grow">
              <span><%= @list.name %></span>
          </div>


          <.link
            phx-click={JS.push("delete_list", value: %{list_id: @list.id}) |> hide("##{@list.id}")}
            data-confirm={"Delete list #{@list.name}?"}
          >
            <.icon name="hero-x-mark-solid" class="h-5 w-5" />
          </.link>
        </div>
      </.inline_input>

      <%= for card <-@list.cards do %>
        <div
          id={"card-#{@list.id}-#{card.id}"}
          draggable="true"
          phx-keydown="deleteCard(event)"
          phx-hook="Drag"
          phx-value-card={card.id}
          class="text-sm"
        >
          <.link patch={~p"/boards/#{@board}/cards/#{card.id}"} phx-value-card={card.id}>
          <div class="p-2 hover:ring-2 ring-neutral-500 bg-white rounded shadow" phx-value-card={card.id}>
            <%= card.name %>
          </div>
          </.link>
        </div>
      <% end %>

      <div>
        <.inline_input class="w-64 mt-1 mb-2 ml-2 h-8" phx-value-card="last" action="new_card" id={@list.id} phx-value-list_id={@list.id}>
          <div phx-hook="Drag" id={"new-button-#{@list.id}"} phx-value-card="last" phx-value-list={@list.id} class="p-2 text-sm font-medium w-full hover:bg-neutral-300">
            <span class="text-xl">+</span> Add a card
          </div>
        </.inline_input>
      </div>
    </div>
    """
  end
end
