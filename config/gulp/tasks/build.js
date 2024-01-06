const gulp = require("gulp");
const runSequence = require("run-sequence");

gulp.task("build", callback => {
  runSequence(
    "clean",
    "font-icon",
    ["styles", "images", "fonts", "scripts"],
    "rev-all",
    callback
  );
});
