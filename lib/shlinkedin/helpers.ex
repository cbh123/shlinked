defmodule Shlinkedin.Helpers do
  @moduledoc """
  Helpers for Shlinkedin.
  """

  def parse_time("hour"), do: -60 * 60
  def parse_time("today"), do: -60 * 60 * 24
  def parse_time("week"), do: parse_time("today") * 7
  def parse_time("month"), do: parse_time("today") * 31
  def parse_time("all_time"), do: parse_time("today") * 31 * 100
end
