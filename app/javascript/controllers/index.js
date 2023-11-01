// Import and register all your controllers from the importmap under controllers/*

import { application } from "controllers/application";

// Eager load all controllers defined in the import map under controllers/**/*_controller
// import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
// eagerLoadControllersFrom("controllers", application)

// Lazy load controllers as they appear in the DOM (remember not to preload controllers in import map!)
// import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"
// lazyLoadControllersFrom("controllers", application)
import ImagesController from "./images_controller";
application.register("images", ImagesController);

import SearchFormController from "./search_form_controller";
application.register("search-form", SearchFormController);

import SpeechController from "./speech_controller";
application.register("speech", SpeechController);
