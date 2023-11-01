// This file is auto-generated by ./bin/rails stimulus:manifest:update
// Run that command whenever you add a new controller or create them with
// ./bin/rails generate stimulus controllerName

import { application } from "./application";

import HelloController from "./hello_controller";
application.register("hello", HelloController);

import ImagesController from "./images_controller";
application.register("images", ImagesController);

import SearchFormController from "./search_form_controller";
application.register("search-form", SearchFormController);

import SpeechController from "./speech_controller";
application.register("speech", SpeechController);
