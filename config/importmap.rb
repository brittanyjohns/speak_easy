# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "@fortawesome/fontawesome-free", to: "https://ga.jspm.io/npm:@fortawesome/fontawesome-free@6.4.2/js/all.js"
pin "cropperjs", to: "https://ga.jspm.io/npm:cropperjs@2.0.0-beta.4/dist/cropper.esm.raw.js"
pin "@cropper/element", to: "https://ga.jspm.io/npm:@cropper/element@2.0.0-beta.4/dist/element.esm.raw.js"
pin "@cropper/element-canvas", to: "https://ga.jspm.io/npm:@cropper/element-canvas@2.0.0-beta.4/dist/element-canvas.esm.raw.js"
pin "@cropper/element-crosshair", to: "https://ga.jspm.io/npm:@cropper/element-crosshair@2.0.0-beta.4/dist/element-crosshair.esm.raw.js"
pin "@cropper/element-grid", to: "https://ga.jspm.io/npm:@cropper/element-grid@2.0.0-beta.4/dist/element-grid.esm.raw.js"
pin "@cropper/element-handle", to: "https://ga.jspm.io/npm:@cropper/element-handle@2.0.0-beta.4/dist/element-handle.esm.raw.js"
pin "@cropper/element-image", to: "https://ga.jspm.io/npm:@cropper/element-image@2.0.0-beta.4/dist/element-image.esm.raw.js"
pin "@cropper/element-selection", to: "https://ga.jspm.io/npm:@cropper/element-selection@2.0.0-beta.4/dist/element-selection.esm.raw.js"
pin "@cropper/element-shade", to: "https://ga.jspm.io/npm:@cropper/element-shade@2.0.0-beta.4/dist/element-shade.esm.raw.js"
pin "@cropper/element-viewer", to: "https://ga.jspm.io/npm:@cropper/element-viewer@2.0.0-beta.4/dist/element-viewer.esm.raw.js"
pin "@cropper/elements", to: "https://ga.jspm.io/npm:@cropper/elements@2.0.0-beta.4/dist/elements.esm.raw.js"
pin "@cropper/utils", to: "https://ga.jspm.io/npm:@cropper/utils@2.0.0-beta.4/dist/utils.esm.raw.js"
pin_all_from "app/javascript/controllers", under: "controllers"
