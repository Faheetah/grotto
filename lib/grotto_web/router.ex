defmodule GrottoWeb.Router do
  use GrottoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {GrottoWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GrottoWeb do
    pipe_through :browser

    get "/", PageController, :home
    live "/boards", BoardLive.Index, :index
    live "/boards/new", BoardLive.Index, :new
    live "/boards/import", BoardLive.Index, :import
    live "/boards/:id", BoardLive.Show, :show
    live "/boards/:id/edit", BoardLive.Show, :edit
    live "/boards/:id/delete", BoardLive.Show, :delete
    live "/boards/:id/export", BoardLive.Index, :export
    live "/boards/:id/archived", BoardLive.Archived, :show
    live "/boards/:id/lists/new", BoardLive.Show, :new_list
    live "/boards/:id/lists/:list_id/cards/new", BoardLive.Show, :new_card
    live "/boards/:id/cards/:card_id", BoardLive.Show, :show_card
  end

  # Other scopes may use custom stacks.
  # scope "/api", GrottoWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:grotto, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: GrottoWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
