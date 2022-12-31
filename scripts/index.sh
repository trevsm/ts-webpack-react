#!/bin/bash

# if no project name echo error and exit
if [[ -z $1 ]]; then
  echo "Please provide a project name"
  exit 1
fi

# if folder name already exists echo error and exit
if [[ -d $1 ]]; then
  echo "Folder already exists"
  exit 1
fi

# Create the project directory and navigate to it
mkdir $1

# Add basic configuration to package.json
cat >$1/package.json <<EOF
{
  "name": "$1",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "build": "webpack --mode production",
    "start": "webpack-dev-server --open --mode development"
  },
  "author": "Your Name",
  "license": "MIT"
}
EOF

mkdir $1/src
mkdir $1/src/assets
mkdir $1/public

# Install dependencies
npm install --prefix $1 --save react react-dom
npm install --prefix $1 --save-dev webpack webpack-cli webpack-dev-server @babel/core @babel/preset-env @babel/preset-react babel-loader css-loader style-loader html-webpack-plugin file-loader clean-webpack-plugin

# Install typescript dependencies
npm install --prefix $1 --save-dev typescript ts-loader @types/react @types/react-dom @types/node @babel/preset-typescript

# Add all files

cat >$1/src/index.tsx <<EOF
import React from "react";
import { StrictMode } from "react";
import { createRoot } from "react-dom/client";

import App from "./App";

const rootElement = document.getElementById("root");
const root = createRoot(rootElement!);

root.render(
  <StrictMode>
    <App />
  </StrictMode>
);
EOF

cat >$1/src/App.tsx <<EOF
import React from "react";
import "./styles.css";
import image from "./assets/placeholder.png";

export default function App() {
  return (
    <div className="App">
      <h1>Example App</h1>
      <img src={image} alt="Placeholder" width={200} />
    </div>
  );
}
EOF

cat >$1/src/styles.css <<EOF
* {
  box-sizing: border-box;
}

html,
body {
  height: 100%;
  margin: 0;
  padding: 0;
}
EOF

cat >$1/public/index.html <<EOF
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Example App</title>
  </head>
  <body>
    <div id="root"></div>
  </body>
</html>
EOF

cat >$1/webpack.config.js <<EOF
/*eslint-disable */
const path = require("path");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const { CleanWebpackPlugin } = require("clean-webpack-plugin");

module.exports = {
  entry: "./src/index.tsx",
  mode: "development",
  devtool: "inline-source-map",
  output: {
    path: path.resolve(__dirname, "build"),
    filename: "[name].bundle.js",
  },
  optimization: {
    splitChunks: {
      chunks: "all",
    },
  },
  module: {
    rules: [
      {
        test: /\.ts(x)?$/,
        exclude: /node_modules/,
        use: [
          {
            loader: "ts-loader",
            options: {
              transpileOnly: true,
            },
          },
          {
            loader: "babel-loader",
            options: {
              presets: [
                "@babel/preset-env",
                "@babel/preset-react",
                "@babel/preset-typescript",
              ],
            },
          },
        ],
      },
      {
        test: /\.css$/i,
        use: ["style-loader", "css-loader"],
      },
      {
        test: /\.(png|svg|jp(e)?g|gif)$/i,
        loader: "file-loader",
        options: {
          name: "[name].[ext]",
        },
      },
    ],
  },
  plugins: [
    new HtmlWebpackPlugin({
      title: "Example Title",
      template: "./public/index.html",
      hash: true,
    }),
    new CleanWebpackPlugin(),
  ],
  resolve: {
    extensions: ["*", ".ts", ".tsx", ".js", ".jsx"],
  },
};
EOF

cat >$1/.eslintrc.json <<EOF
{
  "env": {
    "browser": true,
    "es2021": true
  },
  "extends": [
    "eslint:recommended",
    "plugin:react/recommended",
    "plugin:@typescript-eslint/recommended"
  ],
  "overrides": [],
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "ecmaVersion": "latest",
    "sourceType": "module"
  },
  "ignorePatterns": ["node_modules", "build"],
  "plugins": ["react", "@typescript-eslint"],
  "rules": {
    "react/prop-types": "off",
    "react/react-in-jsx-scope": "off",
    "no-unused-vars": "off",
    "@typescript-eslint/no-unused-vars": "off",
  }
}
EOF

cat >$1/tsconfig.json <<EOF
{
  "compilerOptions": {
    "target": "es5",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "noEmit": false,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noUnusedLocals": true,
    "jsx": "preserve",
    "strictNullChecks": false
  },
  "include": ["src"]
}
EOF

cat >$1/src/assets/modules.d.ts <<EOF
/**
 * This file is used to declare modules that don't have type definitions.
 * In this case, we are declaring modules for png and jpg files, so that
 * we can import them and "ts-loader" won't complain.
 */

declare module '*.png' {
  const value: any
  export default value
}

declare module '*.jpg' {
  const value: any
  export default value
}
EOF

curl https://cdn.discordapp.com/attachments/870398124198354974/1058467907887169669/slippy_jr_a_colorful_neon_programming_software_32bdd529-6bef-4b63-bded-39480cbdcc6b.png --output $1/src/assets/placeholder.png

clear

echo "Project created successfully!"
echo "To run the project, run 'npm start' in the project directory."
