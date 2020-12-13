# Shlinkedin

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

# Charlie's Guide to Learning Elixir / Phoenix Liveview

Hi Dice. I am putting all my thoughts here on how to introduce you to ShlinkedIn code + Elixir / Phoenix. There's a lot of stuff here but do not be discouraged, you will figure it out in no time.

### Terminology
- **Elixir**: self explanatory, elixir language. [Docs](https://elixir-lang.org/getting-started/introduction.html)
- **Phoenix**: a web development framework used for writing web apps in elixir. [Docs](https://hexdocs.pm/phoenix/Phoenix.html)
- **Liveview (or Phoenix Liveview)**: this is built on top of Phoenix, and allows you to easily write real time, interative pages, without writing javascript. [Docs](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html).
- **Tailwind**: the css framework I use for everything, and the reason that the HTML looks messy. It's amazing. [Docs](https://tailwindcss.com)

### Order of operations
1. Watch this video on building a [twitter clone in 15 min](https://www.phoenixframework.org/blog/build-a-real-time-twitter-clone-in-15-minutes-with-live-view-and-phoenix-1-5). A mixture of watching this earlier in the year, and seeing tons of hacker news [rave reviews](https://news.ycombinator.com/item?id=22947341) is what convinced me to try it. Also, as you'll soon see, I started ShlinkedIn 2.0 using the exact code from this project.
2. Take a look at the ShlinkedIn repo, and dig around and see what makes sense to you. I think the most overwhelming part here will probably be the way the project is organized—it feels like a ton of folders and esoteric filenames and impossible to understand. The docs have a very helpful [page on directory structure](https://hexdocs.pm/phoenix/directory_structure.html#content). But here is a concrete example of a page that you can check out and might make sense to you already: go to `lib/shlinkedin_web/live/post_live/index.ex`. On `line 15` you can see the following line:
   ```
       {:ok,
        socket
        |> assign(posts: list_posts())
        |> assign(random_profiles: Shlinkedin.Accounts.get_random_profiles(5))
        |> assign(like_map: Timeline.like_map()), temporary_assigns: [posts: []]}
   ```
   Note how we're assigning to the socket `posts` as `list_posts()`. And `random_profiles` as `Shlinkedin.Accounts.get_random_profiles(5)`. Then, if you navigate to `lib/shlinkedin_web/live/post_live/index.html.leex` you can see the html for how everything is displayed. Fun! One thing to note here, is that the html has a crazy number of class attributes. This may look very messy and ugly to you, but it's actually by design—I'll get to this later but all the CSS is using [tailwind](https://tailwindcss.com), which is all the rage right now and honestly amazing.
3. Go through the "up and running" steps to install Elixir/Phoenix on the Phoenix [docs](https://hexdocs.pm/phoenix/installation.html). These docs are great.
4. For gettings used to Elixir syntax, check out [elixir docs](https://elixir-lang.org/getting-started/introduction.html). The main things I found weird with elixir are:
   - There isn't a `return` keyword. Instead, functions just implicitly return stuff. This is pretty weird, but used to it now.
   -  [pipes](https://elixirschool.com/en/lessons/basics/pipe-operator/) which look like |>, and are used for chaining functions together.
   -  [pattern matching](https://elixir-lang.org/getting-started/pattern-matching.html)
   -  The fact that you don't really use for-loops (instead, it's all just stuff like `Enum.map([1, 2, 3], fn x -> x * 2 end)`). This is tricky but does make code so much cleaner.
5. Learning Phoenix. I used a mixture of the docs, and skimming attached book PDF. Don't want to overwhelm you here, because the [phoenix docs](https://hexdocs.pm/phoenix/Phoenix.html) have pretty much everything you need to know. But the book is still a good resource.
6. Learning Liveview, the [docs](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html) are once again great. I also used this [free course](https://pragmaticstudio.com/courses/phoenix-liveview) which helped.
7. Let me know what questions and comments and thoughts you have! I can try and think of some good starter tasks too.

