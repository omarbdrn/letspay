const app = "./app";
const build = "./public";
const fontName = "app-font";

module.exports = {
  app: app,
  build: build,

  browserSync: {
    notify: false,
    open: false,
    port: 5101,
    files: [build + "/**/*.css"],
    proxy: "localhost:5100",
    ui: {
      port: 5102,
    },
    logConnections: false,
    logFileChanged: true,
    logPrefix: "BrowserSync",
    rewriteRules: [
      {
        match: /<body/,
        fn: function(req, res, match) {
          // Disable Turbolinks on localhost:5001
          // Turbolinks otherwise conflicts with livereload
          if (req.headers.host === "localhost:5101") {
            return '<body data-no-turbolink="true"';
          }
          return "<body";
        },
      },
    ],
  },

  styles: {
    src: app + "/assets/scss",
    files_src: app + "/assets/scss/**/*.scss",
    dest: build + "/assets/css/",
  },

  scripts: {
    files_src: app + "/assets/js/**/*.js",
    main_src: [app + "/assets/js/backoffice.js", app + "/assets/js/payment.js", app + "/assets/js/payment_v2.js"],
    dest: build + "/assets/js/",
  },

  revAll: {
    image_paths: build + "/assets/img/*.{jpg,png,gif,svg}",
    styles_paths: build + "/assets/css/**",
    scripts_paths: build + "/assets/js/**",
    icon_font_paths: build + "/assets/icons/**",
    options: { includeFilesInManifest: [".css", ".js", ".svg", ".png"] },
  },

  images: {
    files_src: [
      "!" + app + "/assets/img/sprite/**/*.svg",
      "!" + app + "/assets/img/sprite.svg",
      app + "/assets/img/**/*.{jpg,png,gif,svg}",
    ],
    dest: build + "/assets/img",
  },

  fonts: {
    src: app + "/assets/fonts/**",
    dest: build + "/assets/fonts",
  },

  font_icon: {
    path_create_icon_font_file: app + "/assets/scss/components/_icons.scss",
    src: app + "/assets/icons",
    files_src: app + "/assets/icons/*.svg",
    path: app + "/assets/scss/shared/tools/_template-font-custom.scss",
    target_path: "../scss/components/_icons.scss",
    font_path: "../fonts/",
    dest: app + "/assets/fonts",
    files_dest: app + "/assets/fonts/" + fontName + ".{eot,svg,ttf,woff}",
    settings: {
      prependUnicode: true,
      font_name: fontName,
      normalize: true,
      font_height: 512,
    },
  },
};
