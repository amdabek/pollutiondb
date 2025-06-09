defmodule PollutiondbWeb.StationLive do
  use PollutiondbWeb, :live_view
  alias Pollutiondb.Station

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        stations: Station.get_all(),
        name: "",
        lat: "",
        lon: ""
      )
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h2>Stacje</h2>
    <form phx-submit="insert">
      <label>Name: <input type="text" name="name" value={@name} /></label><br/>
      <label>Lat: <input type="number" name="lat" step="0.1" value={@lat} /></label><br/>
      <label>Lon: <input type="number" name="lon" step="0.1" value={@lon} /></label><br/>
      <button type="submit">Dodaj</button>
    </form>

    <form phx-change="search">
      <label>Szukanie: <input type="text" name="query" value={@name} /></label>
    </form>

    <table>
      <thead>
        <tr><th>Name</th><th>Lon</th><th>Lat</th></tr>
      </thead>
      <tbody>
        <%= for s <- @stations do %>
          <tr>
            <td><%= s.name %></td>
            <td><%= s.lon %></td>
            <td><%= s.lat %></td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end

  def handle_event("insert", %{"name" => name, "lat" => lat, "lon" => lon}, socket) do
    Station.add(name, to_float(lat, 0.0), to_float(lon, 0.0))
    socket =
      socket
      |> assign(stations: Station.get_all(), name: "", lat: "", lon: "")
    {:noreply, socket}
  end

  def handle_event("search", %{"query" => ""}, socket) do
    {:noreply, assign(socket, stations: Station.get_all())}
  end
  def handle_event("search", %{"query" => query}, socket) do
    {:noreply, assign(socket, stations: Station.find_by_name(query))}
  end

  # pomocnicza
  defp to_float(str, default) do
    case Float.parse(str) do
      {f, _} -> f
      :error -> default
    end
  end
end
