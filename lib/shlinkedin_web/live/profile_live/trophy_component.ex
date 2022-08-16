defmodule ShlinkedinWeb.ProfileLive.TrophyComponent do
  use ShlinkedinWeb, :live_component

  def render(assigns) do
    ~H"""
    <section aria-labelledby="trophies">
    <div class="bg-white rounded-lg shadow">
        <div class="p-6">
            <h2 id="who-to-follow-heading" class={"font-bold text-gray-900 #{@size}"}>Trophy Case</h2>


            <div class="mt-6 flow-root">
                <ul role="list" class="-my-4 divide-y divide-gray-200">

          <%# Empty State %>
          <%= if @current_awards == [] do %>
          <div class="text-center">
              <p class="font-semibold text-gray-600  my-4">Nothing yet. 😔</p>
              <p class="text-xs text-gray-600 italic">Each week, we grant the
                  following awards. Don't give up! </p>
              <%= for type <- @award_types do %>
              <%= if type.name != "Verified" do %>
              <div class={"inline-flex tooltip #{type.color}"}>
                  <%= if type.image_format == "svg" do  %>

                  <svg class="w-4 h-4 " fill="currentColor" viewBox="0 0 20 20"
                      xmlns="http://www.w3.org/2000/svg">
                      <path fill-rule={type.fill} d={type.svg_path}
                          clip-rule={type.fill}>
                      </path>
                  </svg>

                  <% else %>
                  <span class="text-sm">
                      <%= type.emoji %>
                  </span>
                  <% end %>
                  <span class="tooltip-text -mt-8 -ml-24"><%= type.name %></span>
              </div>

              <% end %>
              <% end %>

          </div>
          <% else %>


          <%# Non empty state %>
          <div class="flex overflow-x-scroll">
              <%= for award <- @current_awards do %>
              <div class="flex-1 text-center m-2">
                  <div class={"inline-block #{award.award_type.color}"}>

                      <%= cond do %>
                      <% award.award_type.name == "Platinum" or award.award_type.name == "Shplatinum" -> %>
                      <div class="text-lg">
                          <span style="padding: 1px; --tw-gradient-to: #19f2a3"
                              class="rounded text-white font-medium bg-gradient-to-tr from-blue-400 to-green-400 ">
                              sh
                          </span>
                      </div>


                      <% award.award_type.image_format == "svg" ->  %>
                      <svg class="w-8 h-8 mx-auto " fill="currentColor" viewBox="0 0 20 20"
                          xmlns="http://www.w3.org/2000/svg">
                          <path fill-rule={award.award_type.fill}
                              d={award.award_type.svg_path}
                              clip-rule={award.award_type.fill}>
                          </path>
                      </svg>
                      <% true ->  %>
                      <span class="text-2xl">
                          <%= award.award_type.emoji %>
                      </span>
                      <% end %>

                  </div>
                  <h4 class="text-xs font-semibold mt-2">
                      <%= award.award_type.name %></h4>
                  <p class="mt-1 text-xs text-gray-500">
                      <%= Timex.format!(award.inserted_at, "{Mshort}. {D}, {YYYY}") %>
                  </p>
              </div>
              <% end %>
          </div>
          <% end %>
                    <!-- More people... -->
                </ul>
            </div>

        </div>
    </div>
    </section>
    """
  end
end
