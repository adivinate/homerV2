defmodule HomerWeb.Monetizations.FundingControllerTest do
  use HomerWeb.ConnCase

  alias Homer.Monetizations
  alias Homer.Monetizations.Funding

  @create_attrs %{description: "some description", name: "some name", unit: "some unit", days: 10, validate: 80,
    invests_allows: [
      %{description: "some description for funding", invest: 42, name: "some name for funding"},
      %{description: "again some description for funding", invest: 42, name: "again some name for funding"}
    ],
    step_templates: [
      %{description: "some description", name: "some name", rank: 42},
      %{description: "again some description", name: "again some name", rank: 42}
    ]
  }
  @update_attrs %{description: "some updated description", name: "some updated name", unit: "some updated unit", days: 15, validate: 85,}
  @invalid_attrs %{description: nil, name: nil, unit: nil}

  def fixture(:funding) do
    {:ok, funding} = Monetizations.create_funding(@create_attrs)
    funding
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all fundings", %{conn: conn} do
      conn = HomerWeb.Accounts.LoginControllerTest.auth_user(conn)
      new_conn = get conn, monetizations_funding_path(conn, :index)
      assert json_response(new_conn, 200)["fundings"] == []
    end
  end

  describe "create funding" do
    test "renders funding when data is valid", %{conn: conn} do
      conn = HomerWeb.Accounts.LoginControllerTest.auth_user(conn, true)
      new_conn = post conn, monetizations_funding_path(conn, :create), funding: @create_attrs
      assert %{"id" => id} = json_response(new_conn, 201)["funding"]

      new_conn = get conn, monetizations_funding_path(conn, :show, id)
      response = json_response(new_conn, 200)["funding"]

      value = length Map.get(response, "projects")
      assert value == 0
      value = length Map.get(response, "invests_allows")
      assert value == 2
      value = length Map.get(response, "step_templates")
      assert value == 2

      assert response == %{
        "id" => id,
        "create" => "#{Ecto.DateTime.to_iso8601(Ecto.DateTime.utc)}.000000Z",
        "description" => "some description",
        "name" => "some name",
        "unit" => "some unit",

        "valid" => false,
        "days" => 10,
        "validate" => 80,
        "projects" => [],
        "step_templates" => Map.get(response, "step_templates"),
        "invests_allows" => Map.get(response, "invests_allows")
      }
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = HomerWeb.Accounts.LoginControllerTest.auth_user(conn, true)
      new_conn = post conn, monetizations_funding_path(conn, :create), funding: @invalid_attrs
      assert json_response(new_conn, 422)["errors"] != %{}
    end
  end

  describe "update funding" do
    setup [:create_funding]

    test "renders funding when data is valid", %{conn: conn, funding: %Funding{id: id, create: create} = funding} do
      conn = HomerWeb.Accounts.LoginControllerTest.auth_user(conn, true)
      new_conn = put conn, monetizations_funding_path(conn, :update, funding), funding: @update_attrs
      assert %{"id" => ^id} = json_response(new_conn, 200)["funding"]

      new_conn = get conn, monetizations_funding_path(conn, :show, id)
      response = json_response(new_conn, 200)["funding"]

      value = length Map.get(response, "projects")
      assert value == 0
      value = length Map.get(response, "invests_allows")
      assert value == 2
      value = length Map.get(response, "step_templates")
      assert value == 2

      assert response == %{
        "id" => id,
        "create" => "#{Ecto.DateTime.to_iso8601(create)}.000000Z",
        "description" => "some updated description",
        "name" => "some updated name",
        "unit" => "some updated unit",
        "valid" => false,
        "days" => 15,
        "validate" => 85,
        "projects" => [],
        "step_templates" => Map.get(response, "step_templates"),
        "invests_allows" => Map.get(response, "invests_allows")
      }
    end

    test "renders errors when data is invalid", %{conn: conn, funding: funding} do
      conn = HomerWeb.Accounts.LoginControllerTest.auth_user(conn, true)
      new_conn = put conn, monetizations_funding_path(conn, :update, funding), funding: @invalid_attrs
      assert json_response(new_conn, 422)["errors"] != %{}
    end
  end

  describe "delete funding" do
    setup [:create_funding]

    test "deletes chosen funding", %{conn: conn, funding: funding} do
      conn = HomerWeb.Accounts.LoginControllerTest.auth_user(conn, true)
      new_conn = delete conn, monetizations_funding_path(conn, :delete, funding)
      assert response(new_conn, 204)
      assert_error_sent 404, fn ->
        get conn, monetizations_funding_path(conn, :show, funding)
      end
    end
  end

  describe "access not allow" do
    test "not allow lists all funding", %{conn: conn} do
      conn = get conn, monetizations_funding_path(conn, :index)
      assert json_response(conn, 401)["message"] != %{}
    end

    test "not allow get a funding", %{conn: conn} do
      %Funding{id: id} = fixture(:funding)
      conn = get conn, monetizations_funding_path(conn, :show, id)
      assert json_response(conn, 401)["message"] != %{}
    end

    test "not allow create a funding", %{conn: conn} do
      conn = post conn, monetizations_funding_path(conn, :create), funding: @create_attrs
      assert json_response(conn, 401)["message"] != %{}
    end

    test "cant create a funding", %{conn: conn} do
      conn = HomerWeb.Accounts.LoginControllerTest.auth_user(conn)
      new_conn = post conn, monetizations_funding_path(conn, :create), funding: @create_attrs
      assert new_conn.status == 403
    end

    test "not allow to update a funding", %{conn: conn} do
      user = fixture(:funding)
      conn = put conn, monetizations_funding_path(conn, :update, user), funding: @update_attrs
      assert json_response(conn, 401)["message"] != %{}
    end

    test "cant update a funding", %{conn: conn} do
      conn = HomerWeb.Accounts.LoginControllerTest.auth_user(conn)
      user = fixture(:funding)
      new_conn = put conn, monetizations_funding_path(conn, :update, user), funding: @update_attrs
      assert new_conn.status == 403
    end

    test "not allow to delete a funding", %{conn: conn} do
      user = fixture(:funding)
      conn = delete conn, monetizations_funding_path(conn, :delete, user)
      assert json_response(conn, 401)["message"] != %{}
    end

    test "cant delete a funding", %{conn: conn} do
      conn = HomerWeb.Accounts.LoginControllerTest.auth_user(conn)
      user = fixture(:funding)
      new_conn = delete conn, monetizations_funding_path(conn, :delete, user)
      assert new_conn.status == 403
    end
  end

  defp create_funding(_) do
    funding = fixture(:funding)
    {:ok, funding: funding}
  end
end
