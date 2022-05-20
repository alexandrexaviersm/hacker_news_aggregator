defmodule HackerNewsAggregatorWeb.StoryView do
  use HackerNewsAggregatorWeb, :view
  alias HackerNewsAggregatorWeb.StoryView

  def render("index.json", %{stories: stories}) do
    %{data: render_many(stories, StoryView, "story.json")}
  end

  def render("show.json", %{story: story}) do
    %{data: render_one(story, StoryView, "story.json")}
  end

  def render("story.json", %{story: story}), do: story

  def render("invalid_param.json", _assigns) do
    %{
      errors: %{
        detail:
          "That given parameter number seems to be invalid, please try using a valid Integer for the params number."
      }
    }
  end
end
