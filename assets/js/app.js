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

function scrollDown(document, num_messages) {
  if (num_messages > 6) {
    window.scrollTo(0, document.body.scrollHeight);
  }
}

Hooks.SendMessage = {
  mounted() {
    this.handleEvent("send-message", (e) => {
      const message_input = document.getElementById("message_content");
      message_input.value = "";
      scrollDown(document);
    });
  },
};

Hooks.Message = {
  mounted() {
    this.handleEvent("receive-message", ({ num_messages }) => {
      scrollDown(document, num_messages);
    });
    this.handleEvent("template-message", ({ template }) => {
      document.getElementById("icebreaker").classList.add("hidden");
      const message_input = document.getElementById("message_content");
      message_input.value = template;
    });
    this.handleEvent("scroll-down", ({ num_messages }) => {
      scrollDown(document, num_messages);
    });
    window.addEventListener("scroll", (e) => {
      if (scrollAt() > 95) {
        document.getElementById("scroll_down").classList.add("hidden");
      } else {
        document.getElementById("scroll_down").classList.remove("hidden");
      }
    });
  },
};

Hooks.ScrollDown = {
  mounted() {
    this.el.addEventListener("click", (e) => {
      scrollDown(document, 100);
    });
  },
};

Hooks.CopyToClipboard = {
  mounted() {
    this.el.addEventListener("click", (e) => {
      // @link https://css-tricks.com/copy-paste-the-web/
      // Select the email link anchor text
      const link = this.el.getAttribute("phx-value-link");

      var textarea = document.createElement("textarea");
      textarea.textContent = link;
      textarea.style.position = "fixed"; // Prevent scrolling to bottom of page in Microsoft Edge.
      document.body.appendChild(textarea);
      textarea.select();

      try {
        // Now that we've selected the anchor text, execute the copy command

        let successful = document.execCommand("copy");

        if (!successful) {
          alert(
            "Copy to clipboard failed. Please select the area to copy and use ctrl + c shortcut keys."
          );
        } else {
          alert("Link copied to clipboard");
        }
      } catch (err) {
        console.log(err);
        alert(
          "Copy to clipboard error. Please select the area to copy and use ctrl + c shortcut keys."
        );
      }
    });
  },
};

Hooks.ShareVia = {
  mounted() {
    this.el.addEventListener("click", (e) => {
      const shareData = {
        title: this.el.getAttribute("phx-value-title"),
        text: this.el.getAttribute("phx-value-text"),
        url: this.el.getAttribute("phx-value-link"),
      };

      navigator
        .share(shareData)
        .then(() => console.log("Successful share"))
        .catch((error) => console.log("Error sharing"));
    });
  },
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

Hooks.Bizarro = {
  mounted() {
    this.el.addEventListener("click", (e) => {
      const id = e.target.value;
      const text = document.getElementById(id).value;
      var res = "";
      for (let i = 0; i < text.length; i++) {
        res +=
          i % 2 == 0
            ? text.charAt(i).toUpperCase()
            : text.charAt(i).toLowerCase();
      }
      document.getElementById(id).value = res;
    });
  },
};

Hooks.Clappify = {
  mounted() {
    this.el.addEventListener("click", (e) => {
      const id = e.target.value;
      const textarea = document.getElementById(id);
      textarea.value = textarea.value.replace(/ /g, " 👏 ");
    });
  },
};

function random_emoji() {
  const emojis = [" 👏 ", " 💰 ", " 💪 ", " 💵 ", " 📈 ", " 🧨 ", " 💉 "];
  return emojis[Math.floor(Math.random() * emojis.length)];
}

Hooks.Emojify = {
  mounted() {
    this.el.addEventListener("click", (e) => {
      const id = e.target.value;
      const text = document.getElementById(id).value;

      var res = "";
      for (let i = 0; i < text.length; i++) {
        res += text.charAt(i) == " " ? random_emoji() : text.charAt(i);
      }
      document.getElementById(id).value = res;
    });
  },
};

Hooks.Space = {
  mounted() {
    this.el.addEventListener("click", (e) => {
      const id = e.target.value;
      const textarea = document.getElementById(id);
      textarea.value = textarea.value.replace(/\n/g, "\n\n");
    });
  },
};

Hooks.Yell = {
  mounted() {
    this.el.addEventListener("click", (e) => {
      const id = e.target.value;
      const textarea = document.getElementById(id);
      textarea.value = textarea.value.toUpperCase();
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
