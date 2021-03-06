defmodule HomerWeb.Steps.StepControllerTest do
  use HomerWeb.ConnCase

  alias Homer.Steps
  alias Homer.Steps.Step

  @create_attrs %{name: "some name", description: "some description"}
  @update_attrs %{name: "some new name", description: "some new description"}
  @invalid_attrs %{name: nil, description: nil}

  def fixture(:step) do
    {:ok, step} = Steps.create_step(Homer.StepsTest.get_valid_attrs(@create_attrs))
    step
  end

  def get_create_attrs(attrs \\ %{}), do: Enum.into(@create_attrs, attrs)
  def get_update_attrs(attrs \\ %{}), do: Enum.into(@update_attrs, attrs)

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all steps", %{conn: conn} do
      conn = HomerWeb.Accounts.LoginControllerTest.auth_user(conn)
      new_conn = get conn, steps_step_path(conn, :index)
      assert json_response(new_conn, 200)["steps"] == []
    end
  end

  #describe "create step" do
    #test "renders step when data is valid", %{conn: _conn} do
      #conn = post conn, steps_step_path(conn, :create), step: Homer.StepsTest.get_valid_attrs(@create_attrs)
      #assert json_response(conn, 422)["errors"] != %{}
      #assert %{"id" => id} = json_response(conn, 201)["step"]

      #conn = get conn, steps_step_path(conn, :show, id)
      #assert json_response(conn, 200)["step"] == %{
      #  "id" => id,
      #  "create_at" => "#{Ecto.DateTime.to_iso8601(Ecto.DateTime.utc)}.000000Z"}
      #end

    #test "renders errors when data is invalid", %{conn: _conn} do
      #conn = post conn, steps_step_path(conn, :create), step: Homer.StepsTest.get_valid_attrs(@invalid_attrs)
      #assert json_response(conn, 422)["errors"] != %{}
      #end
  #end

  describe "update step" do
    setup [:create_step]

    test "renders step when data is valid", %{conn: conn, step: %Step{id: id, create_at: create_at} = step} do
      conn = HomerWeb.Accounts.LoginControllerTest.auth_user(conn)
      attrs =
        Map.put(@update_attrs, :step_template_id, step.step_template_id)
        |> Homer.StepsTest.get_valid_attrs

      new_conn = put conn, steps_step_path(conn, :update, step), step: attrs
      assert %{"id" => ^id} = json_response(new_conn, 200)["step"]

      new_conn = get conn, steps_step_path(conn, :show, id)
      assert json_response(new_conn, 200)["step"] == %{
        "id" => id,
        "create_at" => "#{Ecto.DateTime.to_iso8601(create_at)}.000000Z"}
    end

    test "renders errors when fk is invalid", %{conn: conn, step: step} do
      conn = HomerWeb.Accounts.LoginControllerTest.auth_user(conn)
      attrs = Homer.StepsTest.get_valid_attrs(@create_attrs, step)

      bad_step_template = Map.put(attrs, :step_template_id, 1)
      new_conn = put conn, steps_step_path(conn, :update, step), step: bad_step_template
      assert json_response(new_conn, 422)["errors"] != %{}

      bad_project = Map.put(attrs, :project_id, 1)
      new_conn = put conn, steps_step_path(conn, :update, step), step: bad_project
      assert json_response(new_conn, 422)["errors"] != %{}
    end

    test "renders errors when data is invalid", %{conn: conn, step: step} do
      conn = HomerWeb.Accounts.LoginControllerTest.auth_user(conn)
      new_conn = put conn, steps_step_path(conn, :update, step), step: Homer.StepsTest.get_valid_attrs(@invalid_attrs, step)
      assert json_response(new_conn, 422)["errors"] != %{}
    end
  end

  describe "delete step" do
    setup [:create_step]

    test "deletes chosen step", %{conn: conn, step: step} do
      conn = HomerWeb.Accounts.LoginControllerTest.auth_user(conn)
      new_conn = delete conn, steps_step_path(conn, :delete, step)
      assert response(new_conn, 204)
      assert_error_sent 404, fn ->
        get conn, steps_step_path(conn, :show, step)
      end
    end
  end

  describe "access not allow" do
    test "not allow lists all step", %{conn: conn} do
      conn = get conn, steps_step_path(conn, :index)
      assert json_response(conn, 401)["message"] != %{}
    end

    test "not allow get a step", %{conn: conn} do
      %Step{id: id} = fixture(:step)
      conn = get conn, steps_step_path(conn, :show, id)
      assert json_response(conn, 401)["message"] != %{}
    end

    test "not allow to update a step", %{conn: conn} do
      user = fixture(:step)
      conn = put conn, steps_step_path(conn, :update, user), user: @update_attrs
      assert json_response(conn, 401)["message"] != %{}
    end

    test "not allow to delete a step", %{conn: conn} do
      user = fixture(:step)
      conn = delete conn, steps_step_path(conn, :delete, user)
      assert json_response(conn, 401)["message"] != %{}
    end
  end

  defp create_step(_) do
    step = fixture(:step)
    {:ok, step: step}
  end
end
