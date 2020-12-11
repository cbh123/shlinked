defmodule ShlinkedinWeb.PostLive.CommentBubbleComponent do
  use ShlinkedinWeb, :live_component
  alias ShlinkedinWeb.PostLive.PostComponent
  alias Shlinkedin.Timeline.Post


  def handle_event("expand-comment", _, socket) do
    send_update(CommentBubbleComponent, id: socket.assigns.comment.id, expand_comment: true)

    {:noreply, socket}
  end

  def render(assigns) do
    ~L"""
       <%# Top of comment: image, name, title, and time on right %>
       <div class="flex">
       <span class="inline-block cursor-pointer">
           <img class="h-6 w-6 mt-1 rounded-full" src="<%= @comment.profile.photo_url %>" alt="">
       </span>
       <div class=" bg-gray-100 ml-2 py-2 px-4 rounded-lg w-11/12 relative">
           <div class="flex justify-between">
               <%= live_patch to: Routes.profile_show_path(@socket, :show, @comment.profile.slug), class: "text-sm font-semibold text-gray-900 hover:underline" do  %>
               <p class="bold text-xs font-semibold hover:underline cursor-pointer w-64 truncate">
                   <%= @comment.profile.persona_name %>

                   <span
                       class="inline-flex items-center px-2.5 mx-1 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800 ">
                       Author
                   </span>

                   <%= if @profile.id == @comment.profile.id do %>

                   <% end %>

               </p>
               <% end %>
               <p class="text-xs text-gray-500"><%= Timex.from_now(@comment.inserted_at) %></p>
           </div>
           <%# Comment text %>
           <p class="text-xs mt-1 truncate">
               <%= @comment.body %>

               <%# add a see more button %>
               <%= if String.length(@comment.body) >= 20 && !@expand_comment do %>
               <div class="absolute bottom-2 right-2">
                   <button phx-click="expand-post" phx-target="<%= @myself %>"
                       class="text-gray-500 text-sm hover:underline">...see more
                   </button>
               </div>
               <% end %>
           </p>
       </div>
      </div>
    """
  end


end
