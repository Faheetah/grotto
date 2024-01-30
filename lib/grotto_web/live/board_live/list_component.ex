defmodule GrottoWeb.BoardLive.ListComponent do
  use GrottoWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-2 mb-auto bg-neutral-200 space-y-2 w-72 rounded shadow-sm shadow-neutral-400 flex-shrink-0">
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
          class="text-sm"
        >
          <.link patch={~p"/boards/#{@board}/cards/#{card.id}"} phx-value-card={card.id}>
          <div class={"hover:ring-2 ring-neutral-500 bg-white rounded shadow"} phx-value-card={card.id}>
            <%!-- I don't know why I need so many of these phx-value-card={card.id} --%>
            <%= if card.color do %>
            <div class={"rounded-t #{color_card(card.color)} py-2"} phx-value-card={card.id}></div>
            <% end %>
            <div class="p-2" phx-value-card={card.id}>
              <div phx-value-card={card.id}>
                <span class="flex" phx-value-card={card.id}>
                  <span class="grow" phx-value-card={card.id}><%= card.name %></span>
                  <span class="text-neutral-100 font-thin hover:text-neutral-500" phx-value-card={card.id}><%= card.id %>:<%= card.parent_card_id %></span>
                </span>
              </div>

              <div phx-value-card={card.id}>
                <%= if card.description do %>
                  <.icon name="hero-bars-3-bottom-left" class="w-4 h-4" />
                <% end %>
              </div>
            </div>
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
