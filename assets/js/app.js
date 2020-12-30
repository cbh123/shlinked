// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html";
import { Socket } from "phoenix";
import NProgress from "nprogress";
import { LiveSocket } from "phoenix_live_view";

let Uploaders = {};
let Hooks = {};

Uploaders.S3 = function (entries, onViewError) {
  entries.forEach((entry) => {
    let formData = new FormData();
    let { url, fields } = entry.meta;
    Object.entries(fields).forEach(([key, val]) => formData.append(key, val));
    formData.append("file", entry.file);
    let xhr = new XMLHttpRequest();
    onViewError(() => xhr.abort());
    xhr.onload = () => xhr.status === 204 || entry.error();
    xhr.onerror = () => entry.error();
    xhr.upload.addEventListener("progress", (event) => {
      if (event.lengthComputable) {
        let percent = Math.round((event.loaded / event.total) * 100);
        entry.progress(percent);
      }
    });

    xhr.open("POST", url, true);
    xhr.send(formData);
  });
};

const celebrate = [
  "Can you believe I’m as tall as I am? Here's why: \n \n",
  "I think I have a lot to offer! Here’s a bulleted list: \n",
  "Of course, with all that said, it’s worth noting that I am technically better than most people. Why, you ask? Well... \n",
  "It’s my birthday, I’m 47! That’s 47 years of immense, almost tantric pleasure forged in the fires of corporate america. Here are the main lessons I’ve learned in 47 years of hot profit: \n",
  "I’d like to donate my birthday to Tots for Techinicians, a non-profit that takes children from HR managers, and gives them to IT technicians. My generosity is truly endless. Thank you. Alternatively, here are some other charities you may consider donating to, but I get credit because I suggested so on social media: \n",
  "Picture god. Now picture me hucking a handful of sand in their face. I am your god now. If that hasn’t been made clear by the substance of this post, that’s your fault. \n",
  "Wow, I’m valuable! Here's why: \n",
];

const sponsor = [
  "Jamba juice is BETTER than my marriage!",
  "With Jamba Juice, you can harness the power of fruits. #JamOutWithJamba",
  "Uh-oh, it’s #JambaTime! Put down that water and buy a juice!",
  "In addition to everything I'm about to say, I love #JambaJuice. Their fresh ingredients and inventive flavor blends are a gateway to lasting happiness! Try the new Manic Mango Mud Slide!",
  "I lost my virginity at Jamba Juice! #JamOutWithJamba #JambaTime #SexualEncounter",
  "So, I’m sorry to report that my time at my company has come to end after an extremely narrow and targeted round of layoffs, with over 1 employee being let go. I’m looking forward to the next chapter. One thing to keep in mind during these tough times: Jamba Juice’s new Coconut Craze™ smoothie is half-off at participating locations, and is jam-packed with vitamins—and flavor!",
  "Drink Jamba Juice and experience true vigor.",
  "Tired of your job? Quit, and drink Jamba juice.",
];

const crisis = [
  "Believe me, I’ll be the first to admit hiring all those children was a bad idea, but…",
  "So, the stock prices have dropped and 17 investors are dead. But! Before you judge my decisions as a business thought leader, consider the parable of the Frog and the Twig:",
  "First and foremost, we want to say thank you to essential workers. Second, we would like to address the extensive second degree burns most, if not all, of our employees have recently suffered:",
  "Oopsies! We did something bad! ",
  "HELLO IF ANYONE KNOWS HOW TO STOP A POTENTIALLY ECONOMY-TOPPLING COMPUTER VIRUS, PLEASE REACH OUT IMMEDIATELY.",
];

Hooks.Celebrate = {
  mounted() {
    this.el.addEventListener("click", (e) => {
      let btn = document.getElementById("celebrate-btn");
      const post = document.getElementById("post-form_body");

      if (!btn.classList.contains("pressed")) {
        post.textContent = celebrate[Math.floor(Math.random() * crisis.length)];
        btn.classList.add("pressed");
        btn.classList.add("bg-yellow-100");
        btn.classList.add("text-yellow-700");
        btn.classList.add("hover:bg-yellow-100");
        post.focus();
      } else {
        btn.classList.remove("pressed");
        post.textContent = "";
        btn.classList.remove("bg-yellow-100");
        btn.classList.remove("text-yellow-700");
        btn.classList.remove("hover:bg-yellow-100");
      }
      post.focus();
    });
  },
};

Hooks.Sponsor = {
  mounted() {
    this.el.addEventListener("click", (e) => {
      let btn = document.getElementById("sponsor-btn");
      const post = document.getElementById("post-form_body");

      if (!btn.classList.contains("pressed")) {
        post.textContent = sponsor[Math.floor(Math.random() * sponsor.length)];
        btn.classList.add("pressed");
        btn.classList.add("bg-blue-100");
        btn.classList.add("text-blue-700");
        btn.classList.add("hover:bg-blue-100");
      } else {
        btn.classList.remove("pressed");
        post.textContent = "";
        btn.classList.remove("bg-blue-100");
        btn.classList.remove("text-blue-700");
        btn.classList.remove("hover:bg-blue-100");
      }

      post.focus();
    });
  },
};

Hooks.Crisis = {
  mounted() {
    this.el.addEventListener("click", (e) => {
      let btn = document.getElementById("crisis-btn");
      const post = document.getElementById("post-form_body");

      if (!btn.classList.contains("pressed")) {
        post.textContent = crisis[Math.floor(Math.random() * crisis.length)];
        btn.classList.add("pressed");
        btn.classList.add("bg-red-100");
        btn.classList.add("text-red-700");
        btn.classList.add("hover:bg-red-100");
      } else {
        btn.classList.remove("pressed");
        post.textContent = "";
        btn.classList.remove("bg-red-100");
        btn.classList.remove("text-red-700");
        btn.classList.remove("hover:bg-red-100");
      }
      post.focus();
    });
  },
};

Hooks.Pick = {
  mounted() {
    this.el.addEventListener("click", (e) => {
      const textarea = document.getElementById("comment-form_body");

      const name = this.el.getAttribute("phx-value-name");

      textarea.value = textarea.value + name + " ";
      textarea.focus();

      textarea.setSelectionRange(textarea.value.length, textarea.value.length);
    });
  },
};

Hooks.PostPick = {
  mounted() {
    this.el.addEventListener("click", (e) => {
      const textarea = document.getElementById("post-form_body");

      const name = this.el.getAttribute("phx-value-name");

      textarea.value = textarea.value + name + " ";
      textarea.focus();

      textarea.setSelectionRange(textarea.value.length, textarea.value.length);
    });
  },
};

let scrollAt = () => {
  let scrollTop = document.documentElement.scrollTop || document.body.scrollTop;
  let scrollHeight =
    document.documentElement.scrollHeight || document.body.scrollHeight;
  let clientHeight = document.documentElement.clientHeight;

  return (scrollTop / (scrollHeight - clientHeight)) * 100;
};

Hooks.InfiniteScroll = {
  page() {
    return this.el.dataset.page;
  },
  mounted() {
    this.pending = this.page();
    window.addEventListener("scroll", (e) => {
      if (this.pending == this.page() && scrollAt() > 90) {
        this.pending = this.page() + 1;
        this.pushEvent("load-more", {});
      }
    });
  },
  updated() {
    this.pending = this.page();
  },
};

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  uploaders: Uploaders,
  params: { _csrf_token: csrfToken },
});

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", (info) => NProgress.start());
window.addEventListener("phx:page-loading-stop", (info) => NProgress.done());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
