defmodule HomerWeb.Builders.ProjectController do
  use HomerWeb, :controller

  alias Homer.Builders
  alias Homer.Builders.Project

  action_fallback HomerWeb.FallbackController

  def index(conn, _params) do
    projects = Builders.list_projects()
    render(conn, "index.json", projects: projects)
  end

  def create(conn, %{"project" => project_params}) do
    with {:ok, %Project{} = project} <- Builders.create_project(project_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", builders_project_path(conn, :show, project))
      |> render("show.json", project: project)
    end
  end

  def show(conn, %{"id" => id}) do
    project = Builders.get_project!(id)
    render(conn, "show.json", project: project)
  end

  def update(conn, %{"id" => id, "project" => project_params}) do
    project = Builders.get_project!(id)

    with {:ok, %Project{} = project} <- Builders.update_project(project, project_params) do
      render(conn, "show.json", project: project)
    end
  end

  def delete(conn, %{"id" => id}) do
    project = Builders.get_project!(id)
    with {:ok, %Project{}} <- Builders.delete_project(project) do
      send_resp(conn, :no_content, "")
    end
  end
end