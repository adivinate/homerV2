defmodule HomerWeb.Builders.ProjectView do
  use HomerWeb, :view
  alias HomerWeb.Builders.ProjectView

  def render("index.json", %{projects: projects}) do
    %{projects: render_many(projects, ProjectView, "project.json")}
  end

  def render("show.json", %{project: project}) do
    %{project: render_one(project, ProjectView, "project.json")}
  end

  def render("project.json", %{project: project}) do
    project = project
              |> Homer.ViewsConverter.get_id(:steps)
              |> Homer.ViewsConverter.get_id(:investors)
              |> Homer.ViewsConverter.get_id(:funders)
              |> Homer.ViewsConverter.get_id(:funding)

    %{id: project.id,
      name: project.name,
      description: project.description,
      to_raise: project.to_raise,
      create_at: project.create_at,
      status: project.status,
      steps: project.steps,
      github: project.github,
      investors: project.investors,
      funders: project.funders,
      funding: project.funding
    }
  end
end
