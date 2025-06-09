defmodule PollutiondbWeb.StationRangeLive do
  use PollutiondbWeb, :live_view
  alias Pollutiondb.Station

  def mount(_p, _s, socket) do
    socket =
      assign(socket,
        stations: Station.get_all(),
        lat_min: 0.0, lat_max: 5.0,
        lon_min: 0.0, lon_max: 5.0
      )
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h2>Stacje – zakres</h2>
    <form phx-change="update">
      <label>Lat min: <input type="range" name="lat_min" min="0" max="5" step="0.1" value={@lat_min}/></label><br/>
      <label>Lat max: <input type="range" name="lat_max" min="0" max="5" step="0.1" value={@lat_max}/></label><br/>
      <label>Lon min: <input type="range" name="lon_min" min="0" max="5" step="0.1" value={@lon_min}/></label><br/>
      <label>Lon max: <input type="range" name="lon_max" min="0" max="5" step="0.1" value={@lon_max}/></label><br/>
    </form>

    <table>
      <thead><tr><th>Name</th><th>Lon</th><th>Lat</th></tr></thead>
      <tbody>
        <%= for s <- @stations do %>
          <tr>
            <td><%= s.name %></td><td><%= s.lon %></td><td><%= s.lat %></td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end

  def handle_event("update", params, socket) do
    lat_min = to_float(params["lat_min"], socket.assigns.lat_min)
    lat_max = to_float(params["lat_max"], socket.assigns.lat_max)
    lon_min = to_float(params["lon_min"], socket.assigns.lon_min)
    lon_max = to_float(params["lon_max"], socket.assigns.lon_max)

    stations = Station.find_by_location_range(lon_min, lon_max, lat_min, lat_max)

    {:noreply,
      assign(socket,
        lat_min: lat_min, lat_max: lat_max,
        lon_min: lon_min, lon_max: lon_max,
        stations: stations
      )}
  end

  defp to_float(str, default) do
    case Float.parse(str) do
      {f, _} -> f
      :error -> default
    end
  end
end
