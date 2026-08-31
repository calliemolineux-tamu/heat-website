// app/javascript/controllers/event_flyer_controller.js
// Shows a live preview of the selected flyer image before the event form is
// submitted, using an object URL (no upload/round trip needed for the preview).

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview"]

  preview() {
    const file = this.inputTarget.files[0]

    if (this.previewTarget.src && this.previewTarget.src.startsWith("blob:")) {
      URL.revokeObjectURL(this.previewTarget.src)
    }

    if (!file) {
      this.previewTarget.hidden = true
      this.previewTarget.removeAttribute("src")
      return
    }

    this.previewTarget.src = URL.createObjectURL(file)
    this.previewTarget.hidden = false
  }
}
