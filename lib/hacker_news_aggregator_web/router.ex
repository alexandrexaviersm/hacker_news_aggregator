defmodule HackerNewsAggregatorWeb.Router do
  use HackerNewsAggregatorWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :v0 do
    plug(HackerNewsAggregatorWeb.ApiVersion, version: :v0)
  end

  scope "/api", HackerNewsAggregatorWeb do
    pipe_through :api

    scope "/v0" do
      pipe_through(:v0)

      get "/top_stories", StoryController, :top_stories
      get "/get_story/:story_id", StoryController, :get_story
    end
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: HackerNewsAggregatorWeb.Telemetry
    end
  end
end
