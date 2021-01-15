const colors = require("tailwindcss/colors");

module.exports = {
  purge: [
    // "../lib/**/*.ex",
    // "../lib/**/*.leex",
    // "../lib/**/*.eex",
    // "./js/**/*.js",
  ],
  darkMode: false, // or 'media' or 'class'
  theme: {
    fontFamily: {
      times: ["Times New Roman"],
      windows: ["VT323"],
      mono: ["ui-monospace", "SFMono-Regular"],
      creepster: ["Creepster"],
      ibm_plex: ["IBM Plex Serif"],
      metal: ["Metal Mania"],
      marker: ["Permanent Marker"],
    },
    extend: {
      colors: {
        teal: colors.teal,
        gray: colors.blueGray,
      },
    },
  },
  variants: {
    extend: {
      borderColor: ["active"],
      backgroundColor: ["active"],
      textColor: ["active"],
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/custom-forms"),
  ],
};
