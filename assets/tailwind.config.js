module.exports = {
  content: ["./js/**/*.js", "../lib/*_web.ex", "../lib/*_web/**/*.*ex"],
  darkMode: "media", // or 'media' or 'class'
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
      animation: {
        fadeDown: "fadeDown 0.5s ease-out",
        wiggle: "wiggle 0.5s ease-out",
        shake: "shake 0.5s",
      },
      keyframes: {
        wiggle: {
          "0%, 100%": { transform: "rotate(-3deg)" },
          "50%": { transform: "rotate(3deg)" },
        },
        fadeDown: {
          "0%": {
            opacity: "0",
            transform: "translateY(-250px)",
          },
          "100%": {
            opacity: "1",
            transform: "translateY(0)",
          },
        },
        shake: {
          "0%": { transform: "translate(1px, 1px) rotate(0deg);" },
          "10%": { transform: "translate(-1px, -2px) rotate(-1deg);" },
          "20%": { transform: "translate(-3px, 0px) rotate(1deg);" },
          "30%": { transform: "translate(3px, 2px) rotate(0deg);" },
          "40%": { transform: "translate(1px, -1px) rotate(1deg);" },
          "50%": { transform: "translate(-1px, 2px) rotate(-1deg);" },
          "60%": { transform: "translate(-3px, 1px) rotate(0deg);" },
          "70%": { transform: "translate(3px, 1px) rotate(-1deg);" },
          "80%": { transform: "translate(-1px, -1px) rotate(1deg);" },
          "90%": { transform: "translate(1px, 2px) rotate(0deg);" },
          "100%": { transform: "translate(1px, -2px) rotate(-1deg);" },
        },
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
    require("@tailwindcss/aspect-ratio"),
    require("@tailwindcss/typography"),
  ],
};
