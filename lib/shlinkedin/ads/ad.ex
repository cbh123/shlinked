defmodule Shlinkedin.Ads.Ad do
  use Ecto.Schema
  import Ecto.Changeset
  alias Shlinkedin.Ads.Ad
  alias Shlinkedin.Ads
  alias Shlinkedin.Points
  alias Shlinkedin.Profiles.Profile

  schema "ads" do
    field(:body, :string)
    field(:media_url, :string)
    field(:slug, :string)
    belongs_to(:profile, Shlinkedin.Profiles.Profile)
    belongs_to(:owner, Shlinkedin.Profiles.Profile, foreign_key: :owner_id)
    has_many(:clicks, Shlinkedin.Ads.Click, on_delete: :delete_all)
    has_many(:adlikes, Shlinkedin.Ads.AdLike, on_delete: :delete_all)
    field(:company, :string)
    field(:product, :string)
    field(:overlay, :string)
    field(:gif_url, :string)
    field(:overlay_color, :string)
    field(:removed, :boolean, default: false)
    field(:quantity, :integer, default: 1)
    field(:price, Money.Ecto.Amount.Type, default: 100)

    timestamps()
  end

  @doc false
  def changeset(ad, attrs) do
    ad
    |> cast(attrs, [
      :body,
      :media_url,
      :slug,
      :company,
      :product,
      :overlay,
      :overlay_color,
      :gif_url,
      :removed,
      :price,
      :owner_id
    ])
    |> validate_required([:body, :product])
    |> validate_required_inclusion([:gif_url, :media_url])
    |> validate_length(:body, min: 0, max: 250)
    |> validate_length(:company, max: 50)
    |> validate_length(:product, max: 50)
    |> validate_length(:overlay, max: 50)
    |> validate_number(:price, greater_than: 0)
  end

  def validate_required_inclusion(changeset, fields) do
    if Enum.any?(fields, fn field -> get_field(changeset, field) end),
      do: changeset,
      else:
        add_error(
          changeset,
          hd(fields),
          "Make sure you add either a photo or a gif"
        )
  end

  @doc """
  Validates that you have enough balance to create the ad.
  """
  def validate_affordable(
        %Ecto.Changeset{
          data: %Ad{profile_id: profile_id, product: product}
        } = changeset
      ) do
    validate_change(changeset, :price, fn
      :price, price ->
        profile = Shlinkedin.Profiles.get_profile_by_profile_id(profile_id)
        {:ok, cost} = Ads.calc_ad_cost(price)

        cond do
          Money.compare(profile.points, cost) < 0 ->
            [price: "You cannot afford to make this for #{cost}. You have #{profile.points}."]

          cost.amount < 0 ->
            net_worth = profile.points.amount
            tax = (net_worth * -0.1) |> trunc() |> Money.new(:SHLINK)

            Points.generate_wealth_given_amount(profile, tax, "Cheater tax")

            [
              price:
                "\n Ah, we have a cheater in our midst! Subtracting -10% of your net worth (#{tax})"
            ]

          cost.amount > 0 ->
            negative_cost = negative_money(cost)
            Points.generate_wealth_given_amount(profile, negative_cost, "Creating #{product}")
            []
        end
    end)
  end

  @doc """
  Validates that ad price is greater than zero
  """
  def validate_price_not_negative(%Ecto.Changeset{} = changeset) do
    validate_change(changeset, :price, fn
      :price, price ->
        {:ok, cost} = Ads.calc_ad_cost(price)

        if cost.amount <= 0 do
          [price: "Price cannot be negative"]
        else
          []
        end
    end)
  end

  @doc """
  Validates that number of ads created is allowed.
  """
  def validate_ad_creation_limit(
        %Ecto.Changeset{
          data: %Ad{profile_id: profile_id}
        } = changeset,
        max_ads_per_hour
      ) do
    validate_change(changeset, :price, fn
      :price, _price ->
        profile = Shlinkedin.Profiles.get_profile_by_profile_id(profile_id)
        ads_created = Ads.get_number_ads_created(profile)

        if ads_created >= max_ads_per_hour do
          [price: "You can create a maximum of #{max_ads_per_hour} ads per hour."]
        else
          []
        end
    end)
  end

  defp negative_money(%Money{amount: amount} = money) do
    %{money | amount: -amount}
  end

  @doc """
  Validates that profile is allowed to change ad.
  """
  def validate_allowed(changeset, ad, profile) do
    changeset
    |> validate_ad(:body, ad, profile)
    |> validate_ad(:product, ad, profile)
    |> validate_ad(:company, ad, profile)
    |> validate_ad(:price, ad, profile)
    |> validate_ad(:media_url, ad, profile)
    |> validate_ad(:gif_url, ad, profile)
  end

  defp validate_ad(changeset, field, ad, profile) do
    validate_change(changeset, field, fn ^field, _body ->
      if is_allowed?(profile, ad.profile_id) do
        []
      else
        [body: "You cannot edit this person's posts."]
      end
    end)
  end

  def is_allowed?(%Profile{admin: true}, _post_profile_id) do
    true
  end

  def is_allowed?(%Profile{id: id}, ad_profile_id) do
    id == ad_profile_id
  end
end
