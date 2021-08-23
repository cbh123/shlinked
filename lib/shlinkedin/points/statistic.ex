defmodule Shlinkedin.Points.Statistic do
  use Ecto.Schema
  import Ecto.Changeset

  schema "statistics" do
    field :total_points, Money.Ecto.Amount.Type

    timestamps()
  end

  @doc false
  def changeset(statistics, attrs) do
    statistics
    |> cast(attrs, [:total_points])
    |> validate_required([:total_points])
  end
end
