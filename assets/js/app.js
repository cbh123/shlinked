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

const comments = [
  "That’s business for ya!",
  "Who is the man? You are the man.",
  "Grandma?",
  "When the time is right, you’ll know.",
  "How far were you able to throw the child?",
  "If it’s KPIs you’re after, then that’s the way to go.",
  "Sounds like a sticky situation!",
  "Uh-oh, looks like a sticky situation.",
  "That’s a sticky situation if I’ve ever seen one.",
  "I wish you could hear my applause right now.",
  "Maybe… just maybe…",
  "I dig that, my crispy dove!",
  "Slap me some skin, brotha-man!",
  "Well butter me up and call me a biscuit, that’s some thought leadership!",
  "This changes everything.",
  "No thanks, I had a big breakfast.",
  "We should use the wok.",
  "It’s all in the sauce!",
  "You’ve got the sauce, my man!",
  "I need you to search my clothing.",
  "You’re mouth is the spout, and your words are the water.",
  "How exotic!",
  "Life’s a potluck—and you’re servin’ up the main dish!",
  "I’m a star, but you’re an icon.",
  "You walk the walk, AND talk the talk.",
  "You’re my god now!",
  "Forget beef—you’re what’s for dinner!",
  "A trip to the cosmos, perhaps?",
  "You’re the shuttle—I’ll be the fuel. ",
  "You’ve lit a fire under me.",
  "Congratulations, please hire me.",
  "Congrats! Congrats always! Always.",
  "Congratulations you did that thing and are happy now forever!",
  "Uh-oh, sounds like a widdle oopsie-poopsie.",
  "Hah! You daring maverick, you’ve done it again!",
  "I know it may not be “PC” or whatever, but I think that… nevermind.",
  "Let’s talk about gerrymandering now.",
  "I recently listened to a podcast on this very subject. Well done!",
  "I am a podcast now. I am all-seeing.",
  "The real value of business is all the free grains.",
  "Have you met my cousin, Anthony? He is “italian.”",
  "It’s strange… This post gives me such a wistful longing for the summers of my youth. In the orchards, filling my time with nothing but sticks and stones. Before all this, before Dartmouth, the MBA,  before the tie, the corner office… I think I was happy, then. Thanks for sharing!",
  "Zip, zap, zop! You’re not a cop!",
  "Legally, this can’t be held against in court, I think.",
  "If I’m a bug then this post is a can of Raid Max Concentrated Roach and Ant Killer!",
  "Pestilent twerp, you’ll pay for this!",
  "Before starting a career or job, it is good to learn about it. Thank you.",
  "First, they’ll come with knives. Of that much I am certain.",
  "No, no, no!",
  "First of all—the difference between ‘crawfish,’ ‘crawdaddy,’ and ‘crayfish’ is entirely semantic.",
  "Hold MY horses!",
  "Spoons, forks, chopsticks, middle management, tongs. In that order.",
  "I mainly disagree with this because I don’t like you as an individual.",
  "Prove it.",
  "Can you explain it to me as if I were a poorly acclimated foreign exchange student?",
  "Nope. Try again.",
  "Please send help, the ShlinkedIn C-suite has trapped me in their basement offices and I’m running out of food.",
  "Teach me! Teach me more, papa!",
  "I didn’t know Steve Jobs personally, but it’s unlikely you two would get along.",
  "If I may play devil’s advocate for a moment, I actually found The Grand Budapest ",
  "Hotel’s plotting to be trite.",
  "Grocery stores near me.",
  "Platitude, or platypus?",
  "This made my eczema flare up. ",
  "Teach me how to skateboard!",
  "Do you know how to skateboard?",
  "I can almost do a kickflip (on my skateboard).",
  "I like to skateboard!",
  "If you replaced every noun in this with a different one, what would it look like?",
  "In your mind, how do you see this scaling?",
  "For the record, I still can’t find Antigua on a map. And this post didn’t help.",
  "Please answer my calls. ",
  "I’m hungry for BUSINESS!",
  "Don’t dip the pen in the company ink—unless you want stained slacks!",
  "3 lemons, 1 ½  cups sugar, ¼  pounds unsalted butter (room temperature), 4 extra-large eggs, .5 cups lemon juice (3-4 lemons), ⅛ tsp kosher salt",
  "Ugh, you’ve curdled my milk.",
  "Say that to my face, you limp-wristed draft dodger! ",
  "Curses, foiled again!",
  "Hoisted by my own petard!",
  "It’s funny, most people say “chomping at the bit” but the idiom is actually “champing at the bit.” Champing is a normally horse-specific verb meaning to bite upon, or grind with teeth.",
  "You imp! I’ll undermine you every chance I get.",
  "A bowl of ants? Not today, not ever!",
  "A bowl of aunts? Not today, not ever!",
  "Let’s talk. Third-floor of the parking structure. Midnight. Come alone. ",
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

Hooks.Comment = {
  mounted() {
    this.el.addEventListener("click", (e) => {
      let btn = document.getElementById("comment-btn");
      const comment = document.getElementById("comment-form_body");

      comment.textContent =
        comments[Math.floor(Math.random() * comments.length)];

      comment.focus();
    });
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
