defmodule ShlinkedinWeb.OnboardingLive.NameComponent do
  use ShlinkedinWeb, :live_component
  alias Ecto.Changeset

  def update(assigns, socket) do
    whenevent = from_event(assigns.event, assigns.current_user.profile.timezone)
    params = %{}
    changeset = changeset(whenevent, params)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:when, whenevent)
     |> assign(:when_changeset, changeset)
     |> assign_computed(changeset)}
  end

  def
end
