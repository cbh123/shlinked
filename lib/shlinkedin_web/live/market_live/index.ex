defmodule ShlinkedinWeb.MarketLive.Index do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Ads
  alias Shlinkedin.Ads.Ad
  alias Shlinkedin.Points
  alias Shlinkedin.Profiles.Profile
  alias Shlinkedin.Profiles
  alias Shlinkedin.Interns
  alias Shlinkedin.Timeline.Generators

  @impl true
  def mount(_params, session, socket) do
    socket = is_user(session, socket)
    show_sold = show_sold?(socket.assigns.profile)

    sort_options = %{sort_by: :inserted_at, sort_order: :desc, show_sold: show_sold}
    page = 1
    per_page = 6

    ads = Ads.list_ads(paginate: %{page: page, per_page: per_page}, sort: sort_options)

    {:ok,
     socket
     |> assign(
       ads: ads,
       update_action: "append",
       categories: Points.categories(),
       curr_category: "Ads",
       total_pages: calc_max_pages(show_sold, per_page),
       page: page,
       per_page: per_page,
       sort_options: sort_options
     ), temporary_assigns: [ads: []]}
  end

  @impl true
  def handle_params(%{"curr_category" => curr_category}, _url, socket) do
    {:noreply,
     socket
     |> assign(curr_category: curr_category)}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new_ad, _params) do
    socket
    |> assign(:page_title, "Create an Ad")
    |> assign(:ad, %Ad{})
  end

  defp apply_action(socket, :edit_ad, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Ad")
    |> assign(:ad, Ads.get_ad_preload_profile!(id))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "ShlinkMarket")
  end

  def handle_event(
        "toggle_show_sold",
        _params,
        %{assigns: %{profile: profile, sort_options: sort_options}} = socket
      ) do
    show_sold = !sort_options.show_sold
    {:ok, _profile} = Shlinkedin.Profiles.update_profile(profile, %{"show_sold_ads" => show_sold})

    sort_options = Map.replace(sort_options, :show_sold, show_sold)
    total_pages = calc_max_pages(show_sold, socket.assigns.per_page)

    {:noreply,
     socket
     |> assign(
       total_pages: total_pages,
       sort_options: sort_options,
       update_action: "replace",
       page: 1
     )
     |> fetch_ads()}
  end

  def handle_event("buy-intern", _, socket) do
    with {:ok, interns} <-
           calc_intern_cost(socket.assigns.profile) |> check_money(socket.assigns.profile) do
      company_name1 = Generators.company_name()
      company_name2 = Generators.company_name()
      company_name3 = Generators.company_name()

      {:ok, intern} =
        Interns.create_intern(socket.assigns.profile, %{
          name: Interns.get_random_intern_name(),
          age: Enum.random(0..100),
          last_fed: NaiveDateTime.utc_now(),
          address: Generators.address(),
          education: Generators.institution(),
          major: Generators.major(),
          gpa: Generators.gpa(),
          summary: Generators.summary(),
          company1_name: company_name1,
          company1_title: Generators.job_title(),
          company1_job: Generators.job_description(),
          company2_name: company_name2,
          company2_title: Generators.job_title(),
          company2_job: Generators.job_description(),
          company3_name: company_name3,
          company3_title: Generators.job_title(),
          company3_job: Generators.job_description(),
          hobbies: Generators.hobbies(),
          reference: Generators.reference()
        })

      {:noreply,
       socket
       |> put_flash(
         :info,
         "Congrats! You successfully hired #{intern.name}. You now have #{interns} interns."
       )
       |> push_redirect(
         to:
           Routes.profile_show_path(
             socket,
             :show_intern,
             socket.assigns.profile.slug,
             intern.id,
             status: :new_intern
           )
       )}
    else
      {:error, error} ->
        {:noreply,
         socket
         |> put_flash(:error, error)
         |> push_patch(to: Routes.market_index_path(socket, :index))}
    end
  end

  @impl true
  def handle_event("sort_ads", %{"sort-ads" => "Sort by Creation Date"}, socket) do
    sort_options = Map.replace(socket.assigns.sort_options, :sort_by, :inserted_at)

    {:noreply,
     socket
     |> assign(sort_options: sort_options, update_action: "replace", page: 1)
     |> fetch_ads()}
  end

  def handle_event("sort_ads", %{"sort-ads" => "Sort by Price"}, socket) do
    sort_options = Map.replace(socket.assigns.sort_options, :sort_by, :price)

    {:noreply,
     socket
     |> assign(sort_options: sort_options, update_action: "replace", page: 1)
     |> fetch_ads()}
  end

  def handle_event("load-more", _, socket) do
    socket =
      socket
      |> update(:page, &(&1 + 1))
      |> assign(update_action: "append")
      |> fetch_ads()

    {:noreply, socket}
  end

  defp fetch_ads(
         %{assigns: %{page: page, per_page: per_page, sort_options: sort_options}} = socket
       ) do
    ads = Ads.list_ads(paginate: %{page: page, per_page: per_page}, sort: sort_options)

    assign(socket,
      ads: ads
    )
  end

  defp calc_max_pages(show_sold, per_page) do
    total_ads = Ads.get_num_ads(show_sold: show_sold)
    trunc(total_ads / per_page)
  end

  defp show_sold?(nil) do
    []
  end

  defp show_sold?(profile) do
    profile.show_sold_ads
  end

  defp calc_intern_cost(nil), do: Money.new(5000)

  defp calc_intern_cost(%Profile{} = profile) do
    Money.new(5000 * round(:math.pow(2, Profiles.get_interns(profile))))
  end

  defp check_money(cost, %Profile{points: points} = profile) do
    if points.amount >= cost.amount do
      {:ok, Profiles.get_interns(profile) + 1}
    else
      {:error, "You are too poor"}
    end
  end
end
