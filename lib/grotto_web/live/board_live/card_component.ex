defmodule GrottoWeb.BoardLive.CardComponent do
  use GrottoWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-4 min-h-48 overflow-y-visible h-full m-auto">
      <div class="pl-2">
        <.inline_input class="h-8 w-96" value={@card.name} action="rename_card" id={@card.id} phx-value-card_id={@card.id}>
          <div class="text-2xl"><%= @card.name %></div>
        </.inline_input>
        <div class="mt-2 text-md">Created <%= @card.inserted_at %></div>
      </div>

      <div>
        <div id="card-view">
          <.link id="card-viw" onclick={"document.getElementById('card-input').style.display = 'block'; document.getElementById('card-input-field').focus(); document.getElementById('card-view').style.display = 'none';"}>
            <div id="new-button-card" class="h-12 font-medium p-2 w-72 bg-neutral-100 w-full min-h-80 rounded">
                <%= if @card.description do %>
                  <%= for line <- String.split(@card.description, "\n") do %>
                    <div><%= line %></div>
                  <% end %>
                <% else %>
                  <span class="text-neutral-500 font-thin italic">No description</span>
                <% end %>
            </div>
          </.link>

          <.link phx-click={JS.push("delete_card", value: %{id: @card.id})} data-confirm={"Really delete #{@card.name}?"}>
            <.button class="bg-red-200 text-neutral-700 mt-2 p-2" >Delete card</.button>
          </.link>
        </div>

        <div id="card-input" class="hidden h-12 font-medium w-full min-h-48 m-auto">
          <.form for={%{}} :let={f} phx-submit="update_card_description" phx-value-card_id={@card.id} class="h-full m-auto">
            <.input
              field={f[:description]}
              phx-value-card_id={@card.id}
              type="textarea"
              value={@card.description}
              class="w-full min-h-48 m-auto resize-none rounded overflow-y-auto"
              id={"card-input-field"}
            />

            <button type="submit" class="bg-neutral-200 py-2 px-4 rounded">Save</button>

            <.link onclick={"document.getElementById('card-input').style.display = 'none'; document.getElementById('card-view').style.display = 'block';"}>
              Cancel
            </.link>
          </.form>

        </div>
      </div>
    </div>
    """
  end
end
