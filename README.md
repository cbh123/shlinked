# Contributing to Shlinkedin

Hello there, and thanks for contributing to Shlinkedin! This document is largely based off [Phoenix](https://github.com/phoenixframework/phoenix) and is a work in progress.

Shlinkedin, as you can tell, is young -- there are lots of features to build, bugs to fix, and tests to write. So your help is invaluable!



### How to get involved as a technical person

Here are the best ways to contribute, in order of importance:
* Fix bugs. Let me know in the discord, but also, the best case outcome for me is that you submit a PR fixing that bug, with tests included. 
* Are you a freak and like writing tests or documentation? Shlinkedin is certainly lacking in this department. The more tests the better. The more documentation the better.
* Want a new feature? Talk to me in the discord about your idea, and if it makes sense, create a PR and build it! It's still the wild west days of Shlinkin', so I'm happy to add some weird stuff.

Once you pick something to contribute, here's how I suggest you go about it:
1. Join the [discord](https://discord.gg/BkQGryuGjn). 
2. [Learn some amount of Elixir](#My-Guide-to-Learning-Elixir)
3. [Clone ShlinkedIn locally and get it running](#How-to-Run-Shlinkedin-Locally)
4. [Create a pull request](#pull-requests)
5. Request to merge, and I'll either approve it and merge to main, or request changes!
6. Done! Feel free to message me for help at any point along the way.



### How to get involved as a non-technical person

Join the [discord](https://discord.gg/BkQGryuGjn)! This is where the action happens. We are doing this in our spare time and could use a lot of help that isn't writing code. 
* Know a lot about marketing? 
* Are you a decent designer? 
* Have any good ideas whatsoever? 

All of the above are very valuable to us right now!


### Bug reports

Good bug reports are extremely helpful - thank you! Shlinkedin is quite buggy right now, and I expect it to remain that way as we scale.
If you find a bug, the best way to report it is in the [bugs channel on our discord](https://discord.gg/jundjQkpQk).
If you want to try fixing it yourself (which is the best outcome for me), [create a pull request](#pull-requests).


### Feature requests

Feature requests (and feedback in general) is very welcome. Please provide as much detail and context as possible.
The best place to request a feature is in the [features channel on our discord](https://discord.gg/r3CckhMEbt). I'll try and respond and add it to the roadmap if we think it makes sense.

If you want to add a feature yourself (highly encouraged, [create a pull request](#pull-requests)).


### Pull requests

Good pull requests - patches, improvements, new features - are a fantastic
help. They should remain focused in scope and avoid containing unrelated
commits.

**IMPORTANT**: By submitting a patch, you agree that your work will be
licensed under the license used by the project.

If you have any large pull request in mind (e.g. implementing features,
refactoring code, etc), **please ask first** otherwise you risk spending
a lot of time working on something that wemight
not want to merge into the project.

Please adhere to the coding conventions in the project (indentation,
accurate comments, etc.) and don't forget to add your own tests and
documentation. When working with git, we recommend the following process
in order to craft an excellent pull request:

1. [Fork](https://help.github.com/articles/fork-a-repo/) the project, clone your fork,
   and configure the remotes:

   ```bash
   # Clone your fork of the repo into the current directory
   git clone https://github.com/<your-username>/shlinked
   # Navigate to the newly cloned directory
   cd shlinked
   # Assign the original repo to a remote called "upstream"
   git remote add upstream https://github.com/cbh123/shlinked
   ```

2. If you cloned a while ago, get the latest changes from upstream, and update your fork:

   ```bash
   git checkout master
   git pull upstream master
   git push
   ```

3. Create a new topic branch (off of `main`) to contain your feature, change,
   or fix.

   **IMPORTANT**: Making changes in `main` is discouraged. You should always
   keep your local `main` in sync with upstream `main` and make your
   changes in topic branches.

   ```bash
   git checkout -b <topic-branch-name>
   ```

4. Commit your changes in logical chunks. Keep your commit messages organized,
   with a short description in the first line and more detailed information on
   the following lines. Feel free to use Git's
   [interactive rebase](https://help.github.com/articles/about-git-rebase/)
   feature to tidy up your commits before making them public.

5. Make sure all the tests are still passing.

   ```bash
   mix test
   ```

6. Push your topic branch up to your fork:

   ```bash
   git push origin <topic-branch-name>
   ```

7. [Open a Pull Request](https://help.github.com/articles/about-pull-requests/)
    with a clear title and description.

8. If you haven't updated your pull request for a while, you should consider
   rebasing on master and resolving any conflicts.

Thank you for your contributions!


# How to Run Shlinkedin Locally

To start your Phoenix server:

  * Unlock, update, and install dependencies with `mix deps.unlock --all; mix deps.update --all; mix deps.get`
  * Set up a local Postgres instance, you can download a client [here](https://postgresapp.com/)
    * Open Postgres.app and start the server, the rest is handled by Phoneix
  * Create and migrate your database with `mix ecto.setup`. (You may need to first create a postgres user with the credentials listed in ./config/dev.exs — see [this page](https://github.com/phoenixframework/phoenix/issues/2435#issuecomment-320880811) for more info.)
  * `cd assets` and install Node.js dependencies with `npm install` or `yarn install`
  * Return to root directory and start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Other things you may want to do locally

Become an admin:

* First, create a user account.
* Using Postgres, you can do a query like the following:
  * UPDATE profiles SET admin = true WHERE id = 1;
* You can now access [`localhost:4000/admin`](http://localhost:4000/admin)

Enable GIPHY Integration:

* Visit this page to [Request a GIPHY API key](https://support.giphy.com/hc/en-us/articles/360020283431-Request-A-GIPHY-API-Key) and follow the steps.
* Stop your Phoenix server (press `ctrl+C, a, Enter`)
* Set your GIPHY API key an environment variable:
  * `export GIPHY_API_KEY=your_GIPHY_API_key`
* Restart Phoenix with `mix phx.server`

# My Guide to Learning Elixir

I am putting all my thoughts here on how to introduce you to ShlinkedIn code + Elixir / Phoenix. There's a lot of stuff here but do not be discouraged!

### Terminology
- **Elixir**: self explanatory, elixir language. [Docs](https://elixir-lang.org/getting-started/introduction.html)
- **Phoenix**: a web development framework used for writing web apps in elixir. [Docs](https://hexdocs.pm/phoenix/Phoenix.html)
- **Liveview (or Phoenix Liveview)**: this is built on top of Phoenix, and allows you to easily write real time, interative pages, without writing javascript. [Docs](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html).
- **Tailwind**: the css framework I use for everything, and the reason that the HTML looks messy. It's amazing. [Docs](https://tailwindcss.com)

### Order of operations
0. Go through the "up and running" steps to install Elixir/Phoenix on the Phoenix [docs](https://hexdocs.pm/phoenix/installation.html). These docs are great. Then follow the steps above to run Shlinkedin locally on your computer. 
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
3. For gettings used to Elixir syntax, check out [elixir docs](https://elixir-lang.org/getting-started/introduction.html). The main things I found weird with elixir are:
   - There isn't a `return` keyword. Instead, functions just implicitly return stuff. This is pretty weird, but used to it now.
   -  [pipes](https://elixirschool.com/en/lessons/basics/pipe-operator/) which look like |>, and are used for chaining functions together.
   -  [pattern matching](https://elixir-lang.org/getting-started/pattern-matching.html)
   -  The fact that you don't really use for-loops (instead, it's all just stuff like `Enum.map([1, 2, 3], fn x -> x * 2 end)`). This is tricky but does make code so much cleaner.
4. Learning Phoenix. I used a mixture of the docs, and skimming attached book PDF. Don't want to overwhelm you here, because the [phoenix docs](https://hexdocs.pm/phoenix/Phoenix.html) have pretty much everything you need to know. But the book is still a good resource.
4. Learning Liveview, the [docs](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html) are once again great. I also used this [free course](https://pragmaticstudio.com/courses/phoenix-liveview) which helped.
5. Let me know what questions and comments and thoughts you have! I can try and think of some good starter tasks too.


