defmodule Shlinkedin.Tagging do
  use Phoenix.HTML

  def format_tags(body, []) do
    body
  end

  def format_tags(body, tags) do
    String.replace(body, tags, fn prof ->
      profile = Shlinkedin.Profiles.get_profile_by_username(prof)

      case profile do
        nil ->
          body

        profile ->
          Phoenix.HTML.safe_to_string(
            Phoenix.HTML.Link.link("#{prof}",
              to: "/sh/#{profile.slug}",
              class: "text-indigo-600 font-semibold hover:underline cursor-pointer"
            )
          )
      end
    end)
  end

  def check_tagging_mode(body, current_mode) do
    case body |> String.last() do
      "@" -> true
      " " -> false
      _ -> current_mode
    end
  end

  def add_to_query(current_mode, body) do
    case current_mode do
      true ->
        String.split(body, "@") |> List.last()

      false ->
        ""
    end
  end

  def get_search_results(current_mode, query) do
    if current_mode == true, do: Shlinkedin.Profiles.search_profiles(query), else: []
  end
end
