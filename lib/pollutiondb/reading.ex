defmodule Pollutiondb.Reading do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias Pollutiondb.Repo
  alias Pollutiondb.Station

  schema "readings" do
    field :date,  :date
    field :time,  :time
    field :type,  :string
    field :value, :float

    belongs_to :station, Station
    timestamps()
  end

  @required ~w(date time type value station_id)a

  defp changeset(reading, attrs) do
    reading
    |> cast(attrs, @required)
    |> validate_required(@required)
  end

  def add_now(%Station{id: station_id}, type, value) do
    %__MODULE__{}
    |> changeset(%{
      date:       Date.utc_today(),
      time:       Time.utc_now(),
      type:       type,
      value:      value,
      station_id: station_id
    })
    |> Repo.insert()
  end

  def add(%Station{id: station_id}, %Date{} = date, %Time{} = time, type, value) do
    %__MODULE__{}
    |> changeset(%{
      date:       date,
      time:       time,
      type:       type,
      value:      value,
      station_id: station_id
    })
    |> Repo.insert()
  end

  def find_by_date(date) do
    import Ecto.Query, only: [from: 2]

    from(r in __MODULE__, where: r.date == ^date)
    |> Repo.all()
  end

  def last_10() do
    from(r in __MODULE__,
      limit: 10,
      order_by: [desc: r.date, desc: r.time]
    )
    |> Repo.all()
    |> Repo.preload(:station)
  end

  def last_10_by_date(%Date{} = date) do
    from(r in __MODULE__,
      where: r.date == ^date,
      limit: 10,
      order_by: [desc: r.time]
    )
    |> Repo.all()
    |> Repo.preload(:station)
  end


end
