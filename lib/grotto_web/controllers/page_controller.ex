defmodule GrottoWeb.PageController do
  use GrottoWeb, :controller

  def home(conn, _params) do
    # @todo redirect to last page based on user cookie
    redirect(conn, to: "/boards")
  end
end
