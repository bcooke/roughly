defmodule RoughlyWeb.ErrorJSONTest do
  use RoughlyWeb.ConnCase, async: true

  test "renders 404" do
    assert RoughlyWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert RoughlyWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
