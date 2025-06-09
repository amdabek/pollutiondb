defmodule Pollutiondb.Station do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias Pollutiondb.Repo


  schema "stations" do
    field :name, :string
    field :lon,  :float
    field :lat,  :float

    has_many :readings, Pollutiondb.Reading
  end

  def add(attrs) when is_map(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def add(name, lon, lat) do
    add(%{name: name, lon: lon, lat: lat})
  end


  def get_all(),       do: Repo.all(__MODULE__)
  def get_by_id(id),   do: Repo.get(__MODULE__, id)
  def remove(station), do: Repo.delete(station)

  def find_by_name(name) do
    from(s in __MODULE__, where: s.name == ^name)
    |> Repo.all()
  end

  def find_by_location(lon, lat) do
    from(s in __MODULE__,
      where: s.lon == ^lon,
      where: s.lat == ^lat
    )
    |> Repo.all()
  end

  def find_by_location_range(lon_min, lon_max, lat_min, lat_max) do
    from(s in __MODULE__,
      where: s.lon  >= ^lon_min and s.lon  <= ^lon_max,
      where: s.lat  >= ^lat_min and s.lat  <= ^lat_max
    )
    |> Repo.all()
  end

  def update_name(station, new_name) do
    station
    |> changeset(%{name: new_name})
    |> Repo.update()
  end

  defp changeset(station, attrs) do
    station
    |> cast(attrs, [:name, :lon, :lat])
    |> validate_required([:name, :lon, :lat])
    |> unique_constraint(:name)
  end

end
