defmodule RoughlyWeb.PageController do
  use RoughlyWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
