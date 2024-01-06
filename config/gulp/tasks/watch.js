const gulp = require("gulp");
const config = require("../config");
const browserSync = require("browser-sync");
const watch = require("gulp-watch");
const runSequence = require("run-sequence");

gulp.task("watch", () => {
  watch(config.styles.files_src, "./app/assets", function() {
    runSequence("styles", "styleguide");
  });

  watch(config.images.files_src, () => {
    runSequence("images", browserSync.reload);
  });

  watch(config.font_icon.files_src, () => {
    runSequence("font-icon", "styles", browserSync.reload);
  });

  watch(config.fonts.src, () => {
    runSequence("fonts", browserSync.reload);
  });
});
