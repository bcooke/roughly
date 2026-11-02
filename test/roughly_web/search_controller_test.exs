defmodule RoughlyWeb.SearchControllerTest do
  use RoughlyWeb.ConnCase
  import Roughly.QuestionFixtures

  test "public suggestions are bounded and contain no private response data", %{conn: conn} do
    q = question(%{text: "Do you like coffee?", slug: "coffee"})
    response_fixture(q, "Yes")
    result = conn |> get(~p"/api/search/suggest?q=coffee") |> json_response(200)
    assert [%{"slug" => "coffee", "total" => 1}] = result["questions"]
    assert [%{"name" => "Food & drink"}] = result["topics"]
    refute Map.has_key?(hd(result["questions"]), "principal_uuid")
  end

  test "malformed search input is refused", %{conn: conn} do
    assert %{"error" => _} = conn |> get("/api/search/suggest?q[]=coffee") |> json_response(400)
  end
end
