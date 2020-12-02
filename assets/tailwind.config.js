module.exports = {
  purge: [],
  darkMode: false, // or 'media' or 'class'
  theme: {
    fontFamily: {
      'times': ["Times New Roman"],
      'windows': ["VT323"],
      'mono': ['ui-monospace', 'SFMono-Regular']
    }
  },
  variants: {
    extend: {
        borderColor: ['active']
    }
  },
  plugins: [require("@tailwindcss/forms"), require("@tailwindcss/custom-forms")]
};
