defmodule HomerWeb.Monetization.FundingView do
  use HomerWeb, :view
  alias HomerWeb.Monetization.FundingView

  def render("index.json", %{fundings: fundings}) do
    %{fundings: render_many(fundings, FundingView, "funding.json")}
  end

  def render("show.json", %{funding: funding}) do
    %{funding: render_one(funding, FundingView, "funding.json")}
  end

  def render("funding.json", %{funding: funding}) do
    %{id: funding.id,
      name: funding.name,
      description: funding.description,
      unit: funding.unit,
      create: funding.create,
      valid: funding.valid}
  end
end