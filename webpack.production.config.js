var path = require("path");
var webpack = require("webpack");

module.exports = {
  watch: false, // dynamically changed by gulp

  devtool: "source-map",

  output: {
    filename: "[name].js",
    publicPath: "/",
  },

  // Exposing external libs (loaded from cdn)
  externals: {
    jquery: "jQuery",
  },

  resolve: {
    extensions: ["", ".vue", ".js", ".json"],
    root: [path.resolve("./app/assets/js/"), path.resolve("./app/assets/scss/")],
  },

  module: {
    loaders: [
      {
        test: /\.vue$/,
        loaders: ["vue"],
      },
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loaders: [
          "babel", // babel config is located in .babelrc
        ],
      },
      {
        test: /\.json$/,
        loaders: ["json"],
      },
    ],
  },

  plugins: [
    // Force NODE_ENV='production'
    new webpack.DefinePlugin({
      "process.env": {
        NODE_ENV: JSON.stringify("production"),
      },
    }),
    new webpack.optimize.AggressiveMergingPlugin(),
    new webpack.optimize.UglifyJsPlugin({
      sourceMap: true,
      compress: {
        sequences: true,
        dead_code: true,
        conditionals: true,
        booleans: true,
        unused: true,
        if_return: true,
        join_vars: true,
        drop_console: true,
        warnings: false, // Disable warnings. Set to true when checking for issues
      },
      mangle: {
        except: ["$super", "$", "exports", "require"],
      },
      output: {
        comments: false,
      },
    }),
  ],
};
