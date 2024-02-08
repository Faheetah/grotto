defmodule GrottoWeb.BoardLive.ListComponent do
  use GrottoWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-1 mb-auto bg-neutral-200 w-72 rounded shadow-sm shadow-neutral-400 flex-shrink-0">
      <.inline_input class="h-8 w-full my-1" value={@list.name || ""} action="rename_list" id={@list.id} phx-value-list_id={@list.id}>
        <div class="p-2 flex font-bold text-sm">
          <div class="grow">
              <span><%= @list.name %></span>
          </div>

          <.link class="mr-2 text-neutral-200 hover:text-neutral-600" phx-click={JS.push("fix_list", value: %{list_id: @list.id})}>
            fix
          </.link>

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
          phx-hook="Drag"
          phx-value-card={card.id}
          class="text-sm p-1"
        >
          <.link patch={~p"/boards/#{@board}/cards/#{card.id}"}>
          <div class={"hover:ring-2 ring-neutral-500 bg-white rounded shadow"}>
            <%= if card.color do %>
            <div class={"rounded-t #{color_card(card.color)} py-2"}></div>
            <% end %>
            <div class="p-2">
              <div>
                <%= card.name %>
              </div>

              <div>
                <%= if card.description do %>
                <div title={card.description}>
                  <.icon title={card.description} name="hero-bars-3-bottom-left" class="w-4 h-4" />
                </div>
                <% end %>
              </div>
            </div>
          </div>
          </.link>
        </div>
      <% end %>

      <div >
        <.inline_input class="w-64 mt-1 mb-2 ml-2 h-8" action="new_card" id={@list.id}>
          <div phx-value-card="last" phx-value-list={@list.id} phx-hook="Drag" id={"new-button-#{@list.id}"} class="p-2 text-sm font-medium w-full hover:bg-neutral-300">
            <span class="text-xl">+</span> Add a card
          </div>
        </.inline_input>
      </div>
    </div>
    """
  end
end
