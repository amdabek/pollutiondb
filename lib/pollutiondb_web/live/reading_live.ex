defmodule PollutiondbWeb.ReadingLive do
  use PollutiondbWeb, :live_view
  alias Pollutiondb.{Reading, Station}

  def mount(_p, _s, socket) do
    today = Date.utc_today()

    socket =
      assign(socket,
        readings: Reading.last_10(),
        stations: Station.get_all(),
        date: today,
        type: "",
        value: "",
        station_id: nil
      )
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h2>Odczyty</h2>

    <form phx-change="filter">
      <label>Data:
        <input type="date" name="date" value={@date} />
      </label>
    </form>

    <table>
      <thead>
        <tr><th>Stacja</th><th>Data</th><th>Godz.</th><th>Typ</th><th>Wartość</th></tr>
      </thead>
      <tbody>
        <%= for r <- @readings do %>
          <tr>
            <td><%= r.station.name %></td>
            <td><%= r.date %></td>
            <td><%= r.time %></td>
            <td><%= r.type %></td>
            <td><%= r.value %></td>
          </tr>
        <% end %>
      </tbody>
    </table>

    <h3>Dodaj odczyt</h3>
    <form phx-submit="insert">
      <label>Stacja:
        <select name="station_id">
          <%= for s <- @stations do %>
            <option value={s.id} selected={s.id == @station_id}><%= s.name %></option>
          <% end %>
        </select>
      </label><br/>
      <label>Typ: <input type="text" name="type" value={@type}/></label><br/>
      <label>Wartość: <input type="number" name="value" step="0.1" value={@value}/></label><br/>
      <button type="submit">Dodaj odczyt</button>
    </form>
    """
  end

  def handle_event("filter", %{"date" => ""}, socket) do
    {:noreply, assign(socket, readings: Reading.last_10(), date: socket.assigns.date)}
  end
  def handle_event("filter", %{"date" => date_str}, socket) do
    date = to_date(date_str, socket.assigns.date)
    readings = Reading.last_10_by_date(date)
    {:noreply, assign(socket, readings: readings, date: date)}
  end

  def handle_event("insert", %{"station_id" => sid, "type" => type, "value" => val}, socket) do
    station = %Station{id: to_int(sid, 1)}
    Reading.add_now(station, type, to_float(val, 0.0))

    {:noreply,
      socket
      |> assign(readings: Reading.last_10())
      |> assign(type: "", value: "", station_id: nil)}
  end

  defp to_date(str, default) do
    case Date.from_iso8601(str) do
      {:ok, d} -> d
      _ -> default
    end
  end

  defp to_float(str, default) do
    case Float.parse(str) do
      {f, _} -> f
      _ -> default
    end
  end

  defp to_int(str, default) do
    case Integer.parse(str) do
      {i, _} -> i
      _ -> default
    end
  end
end
