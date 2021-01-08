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
import Typed from "typed.js";

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

Hooks.OnboardingPrompt = {
  mounted() {
    this.el.addEventListener("click", (e) => {
      const id = e.target.id.split("-")[0];
      var typed = new Typed(`#${id}`, {
        stringsElement: `#${id}-text`,
        typeSpeed: 5,
      });
    });
  },
};

Hooks.CommentPickTag = {
  mounted() {
    this.el.addEventListener("click", (e) => {
      const textarea = document.getElementById("comment-form_body");

      const name = this.el.getAttribute("phx-value-name");

      const body = textarea.value;
      const split = body.split("@");
      const tag = split[split.length - 1];
      const sliced_body = body.replace(tag, "");
      const new_body = sliced_body + name + " ";

      textarea.value = new_body;
      textarea.focus();

      textarea.setSelectionRange(textarea.value.length, textarea.value.length);
    });
  },
};

Hooks.PostPickTag = {
  mounted() {
    this.el.addEventListener("click", (e) => {
      const textarea = document.getElementById("post-form_body");

      const name = this.el.getAttribute("phx-value-name");

      const body = textarea.value;
      const split = body.split("@");
      const tag = split[split.length - 1];
      const sliced_body = body.replace(tag, "");
      const new_body = sliced_body + name + " ";

      textarea.setSelectionRange(textarea.value.length, textarea.value.length);
    });
  },
};

Hooks.OpenNavMenu = {
  mounted() {
    this.el.addEventListener("click", (e) => {
      console.log(e);
      const menu = document.getElementById("nav-menu");
      menu.removeClass("hidden");
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
