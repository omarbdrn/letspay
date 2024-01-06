var gulp = require("gulp");
var RevAll = require("gulp-rev-all");
var awspublish = require("gulp-awspublish");
var cloudfront = require("gulp-cloudfront");
var config = require("../config");
var gzip = require("gulp-gzip");
var gulpif = require("gulp-if");
var rename = require("gulp-rename");
var parallelize = require("concurrent-transform");
var options = require("minimist")(process.argv.slice(2));

var ENV = process.env.RAILS_ENV;

var aws = {
  params: {
    Bucket: process.env.AWS_BUCKET,
  },
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  distributionId: "",
  region: process.env.AWS_REGION,
};

var deploy_on_aws = options.production;

gulp.task("rev-all", function() {
  if (options.production) {
    var publisher = awspublish.create(aws);
    return gulp
      .src(config.build + "/assets/**")
      .pipe(gulp.dest(config.build + "/assets"))
      .pipe(RevAll.revision(config.revAll.options))
      .pipe(gulp.dest(config.build + "/assets"))
      .pipe(
        rename(function(path) {
          if (process.env.HEROKU_APP_NAME) {
            path.dirname =
              "/" + process.env.HEROKU_APP_NAME + "/assets/" + path.dirname;
          } else if (deploy_on_aws) {
            path.dirname =
              "/" + process.env.RAILS_ENV + "/assets/" + path.dirname;
          } else {
            path.dirname = "/assets/" + path.dirname;
          }
        })
      )
      .pipe(gulpif(deploy_on_aws, awspublish.gzip()))
      .pipe(
        gulpif(
          deploy_on_aws,
          parallelize(
            publisher.publish({
              "Cache-Control": "max-age=315360000, no-transform, public",
            }),
            10
          )
        )
      )
      .pipe(gulpif(deploy_on_aws, awspublish.reporter()))
      .pipe(RevAll.manifestFile())
      .pipe(
        rename(function(path) {
          if (process.env.HEROKU_APP_NAME) {
            path.dirname =
              "/" + process.env.HEROKU_APP_NAME + "/assets/" + path.dirname;
          } else if (deploy_on_aws) {
            path.dirname =
              "/" + process.env.RAILS_ENV + "/assets/" + path.dirname;
          } else {
            path.dirname = "/assets/" + path.dirname;
          }
        })
      )
      .pipe(
        gulpif(
          deploy_on_aws,
          publisher.publish({
            "Cache-Control": "no-cache, no-store, must-revalidate",
          })
        )
      )
      .pipe(gulpif(deploy_on_aws, awspublish.reporter()));
  } else {
    return gulp
      .src(config.build + "/assets/**")
      .pipe(gulp.dest(config.build + "/assets"));
  }
});
