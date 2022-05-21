defmodule HackerNewsAggregatorWeb.StoryViewTest do
  use HackerNewsAggregatorWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  alias HackerNewsAggregator.Stories.Story
  alias HackerNewsAggregatorWeb.StoryView

  setup do
    [story: %Story{id: "123", title: "foo title", by: "John Doe"}]
  end

  test "renders index.json", %{story: story} do
    stories = [story | [%Story{id: "456", title: "bar title", by: "Erlang Solutions"}]]

    assert render(StoryView, "index.json", %{stories: stories}) == %{
             data: [
               %Story{by: "John Doe", id: "123", score: nil, title: "foo title", url: nil},
               %Story{by: "Erlang Solutions", id: "456", score: nil, title: "bar title", url: nil}
             ]
           }
  end

  test "renders show.json", %{story: story} do
    assert render(StoryView, "show.json", %{story: story}) == %{
             data: %Story{by: "John Doe", id: "123", score: nil, title: "foo title", url: nil}
           }
  end

  test "renders story.json", %{story: story} do
    assert render(StoryView, "story.json", %{story: story}) == %Story{
             by: "John Doe",
             id: "123",
             score: nil,
             title: "foo title",
             url: nil
           }
  end

  test "renders invalid_param.json" do
    assert render(StoryView, "invalid_param.json", %{}) == %{
             errors: %{
               detail:
                 "That given parameter number seems to be invalid, please try using a valid Integer for the params number."
             }
           }
  end
end
