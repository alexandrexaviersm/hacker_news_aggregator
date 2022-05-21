# HackerNewsAggregator

## Docker Setup

To start the Application with Docker:
#### Build
```
docker build -t hacker-news/aggregator .
```
#### Run
```
docker run --rm -p 4000:4000 --name=aggregator hacker-news/aggregator
```

## Local Setup

To start your Phoenix server in your local env:
#### Erlang / Elixir
Install Erlang and Elixir - one way to install it is by running `asdf install` to install the correct version of Erlang and Elixir (if you use asdf as a package manager)
#### Install dependencies
`mix deps.get`
#### Start Phoenix endpoint
`mix phx.server` or inside IEx with `iex -S mix phx.server`

## Usage
Once the application starts, new stories will be pulled from the Hacker News API and they will be available via two public APIs: JSON over http and JSON over WebSockets.

Now you can now test the application by visiting the following URL from your browser (the data will already be saved in memory (ETS table):

#### List stories with pagination (10 results per page)
[`http://localhost:4000/api/v0/top_stories`](http://localhost:4000/api/v0/top_stories)

[`http://localhost:4000/api/v0/top_stories?page=3`](http://localhost:4000/api/v0/top_stories?page=3)

#### Fetch a single story using the story id
[`http://localhost:4000/api/v0/get_story/31445753`](http://localhost:4000/api/v0/get_story/31445753)

[`http://localhost:4000/api/v0/get_story/31452449`](http://localhost:4000/api/v0/get_story/31452449)

#### You can use a CLI application to test the WebSocket
Use `npm install -g wscat` in order to get started. Copy the input that is on the > line below.
```
$ wscat -c 'ws://localhost:4000/socket/websocket?vsn=2.0.0'
connected (press CTRL+C to quit)
> ["1","1","stories:lobby","phx_join",{}]
```
The WebSockets api should send the 50 top stories right after you joined the stories:lobby

After 5 minutes, the server will poll the Hacker News API again and the top 50 stories will be sent to connected customers and also will be available via HTTP.
