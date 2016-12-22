var webpack = require("webpack"),
    ExtractTextPlugin = require("extract-text-webpack-plugin"),
    HtmlWebpackPlugin = require("html-webpack-plugin");


module.exports = {
    context: __dirname + "/ratel/web/frontend",
    entry: ["whatwg-fetch", "./src/index.js"],
    output: {
        path: __dirname + "/ratel/web/frontend/build",
        filename: "static/[name].js"
    },
    module: {
        loaders: [
            {
                test: /\.jsx?$/,
                exclude: /(node_modules|bower_components)/,
                loader: "babel", // 'babel-loader' is also a valid name to reference
                query: {
                  presets: ["es2015", "react"]
                }
            },
            { test: /\.css$/, loader: ExtractTextPlugin.extract("style-loader", "css-loader") },
            { test: /\.(ttf|eot|svg|woff2?)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
              loader: "file-loader?name=static/[hash].[ext]&publicPath=/" }
        ]
    },
    plugins: [
        new ExtractTextPlugin("static/[name].css"),
        new HtmlWebpackPlugin({
            template: "index.html",
            inject: false
        })
    ]
};
