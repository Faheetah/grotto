defmodule GrottoWeb.BoardLive.ListComponent do
  use GrottoWeb, :live_component


  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :tz_offset, Map.get(socket.private.connect_params, "tz_offset"))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="grow shrink-0 overflow-y-auto pt-1 px-2 mb-auto border max-h-full bg-neutral-100 border-neutral-200 rounded min-w-80 max-w-80">
      <.inline_input class="h-8 w-full my-1 rounded-lg" value={@list.name || ""} action="rename_list" id={@list.id} phx-value-list_id={@list.id}>
        <div class="p-2 flex font-bold text-sm">
          <div class="grow">
              <span><%= @list.name %></span>
          </div>

          <.link class="mr-2 text-neutral-100 hover:text-neutral-400" phx-click={JS.push("fix_list", value: %{list_id: @list.id})}>
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

      <.inline_input class="h-4 ml-2 w-12 rounded" value={@list.rank || 0} action="rerank_list" id={@list.id} phx-value-list_id={@list.id}>
        <div class="text-xs mb-2 ml-2 text-neutral-200">rank:<%= @list.rank || "NOTSET" %></div>
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
          <div class={"hover:ring-2 ring-neutral-500 bg-white rounded border shadow border-neutral-200"}>
            <%= if card.color do %>
            <div class={"rounded-t #{color_card(card.color)} py-2"}></div>
            <% end %>
            <div class="p-2 break-words">
              <div>
                <%= card.name %>
              </div>

              <.local_time time={card.due_date} tz={@tz_offset} />

              <div>
                <%= if card.description do %>
                <div title={card.description}>
                  <.icon name="hero-bars-3-bottom-left" class="w-4 h-4" />
                </div>
                <% end %>
              </div>
            </div>
          </div>
          </.link>
        </div>
      <% end %>

      <div class="mb-2">
        <.inline_input class="w-64 mt-1 mb-2 ml-2 h-8" action="new_card" phx-value-list_id={@list.id} id={@list.id}>
          <div phx-value-card="last" phx-value-list={@list.id} phx-hook="Drag" id={"new-button-#{@list.id}"} class="px-2 pt-1 pb-2 m-2 my-2 text-sm font-medium cursor-pointer rounded hover:bg-neutral-200">
            <span class="text-xl">+</span> Add a card
          </div>
        </.inline_input>
      </div>
    </div>
    """
  end
end
