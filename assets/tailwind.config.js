module.exports = {
  purge: [],
  darkMode: false, // or 'media' or 'class'
  theme: {
    fontFamily: {
      'times': ["Times New Roman"]
    }
  },
  variants: {
    extend: {}
  },
  plugins: [require("@tailwindcss/forms"), require("@tailwindcss/custom-forms")]
};
