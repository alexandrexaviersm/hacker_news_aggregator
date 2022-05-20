defmodule HackerNewsAggregatorWeb.StoryController do
  use HackerNewsAggregatorWeb, :controller

  alias HackerNewsAggregator.Stories
  alias HackerNewsAggregator.Stories.Story

  action_fallback HackerNewsAggregatorWeb.FallbackController

  def top_stories(%{assigns: %{api_version: :v0}} = conn, params) do
    page = params["page"] || "1"

    with {:ok, page_number} <- parse_param(page),
         {:ok, stories} <- Stories.get_stories_from_storage(page_number) do
      render(conn, "index.json", %{stories: stories})
    end
  end

  def get_story(%{assigns: %{api_version: :v0}} = conn, %{"story_id" => story_id}) do
    with {:ok, story_id} <- parse_param(story_id),
         {:ok, %Story{} = story} <- Stories.get_story_from_storage(story_id) do
      render(conn, "show.json", %{story: story})
    end
  end

  defp parse_param(param) do
    case Integer.parse(param) do
      :error -> {:error, :invalid_param}
      {param_number, _} -> {:ok, param_number}
    end
  end
end
