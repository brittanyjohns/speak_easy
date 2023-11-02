// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
//= require sortable

// import "@hotwired/turbo-rails";
// import "@fortawesome/fontawesome-free";
// import "./controllers";
console.log("Stimulus loading...");

import { Application } from "@hotwired/stimulus";

const application = Application.start();

// // Configure Stimulus development experience
application.debug = true;
// window.Stimulus   = application

import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers";

window.Stimulus = application;
const context = require.context("./controllers", true, /\.js$/);
Stimulus.load(definitionsFromContext(context));
console.log("Stimulus loaded");
export { application };
