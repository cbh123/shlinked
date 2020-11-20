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

let Hooks = {};

Hooks.Celebrate = {
  mounted() {
    this.el.addEventListener("click", e => {
      const post = document.getElementById("post-form_body");
      let c = document.getElementById("celebrate-btn");

      // If not clicked
      if (c.value == 0) {
        if (post.value == "") {
          post.value = " ! ";
        }
        post.value = " " + post.value.toUpperCase() + " ";
        c.textContent = "Celebrate even more";
        c.value = 1;
        // Clicked once
      } else if (c.value == 1) {
        c.textContent = "EVEN MORE!!!";
        post.value = post.value.replace(/ /g, " 👏 ");
        c.value = 2;
        // Clicked twice
      } else if (c.value == 2) {
        post.value = post.value.replace(/ /g, " 👏 ");
        post.value = post.value += "\n\nBOW DOWN BEFORE ME.";
        c.value = 3;
      } else if (c.value == 3) {
        post.value = post.value.replace(/ /g, " 👏 ");
        post.value = "I AM YOUR GOD NOW \n\n" + post.value;
        c.textContent = "nevermind";
        c.value = 4;
      } else if (c.value == 4) {
        c.textContent = "Celebrate";
        post.value = "";
        c.value = 1;
      }
    });
  }
};

const ads = [
  "I love Jamba Juice! #JamOutWithJamba",
  "Jamba Juice. There's nothing like it.",
  "Celebrate the Flavors of Life. Jamba Juice",
  "I love Jamba! Blend in the Good®"
];

Hooks.Sponsor = {
  mounted() {
    this.el.addEventListener("click", e => {
      let ad = document.getElementById("sponsorship");
      let btn = document.getElementById("sponsor-btn");
      let adCopy = document.getElementById("ad-copy");

      if (ad.classList.contains("hidden")) {
        adCopy.textContent = ads[Math.floor(Math.random() * ads.length)];
        ad.classList.remove("hidden");
        btn.textContent = "Unsponsor";
      } else {
        ad.classList.add("hidden");
        btn.textContent = "Sponsor";
      }
    });
  }
};

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: Hooks
});

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start());
window.addEventListener("phx:page-loading-stop", info => NProgress.done());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
