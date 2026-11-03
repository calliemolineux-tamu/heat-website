import { Controller } from "@hotwired/stimulus"

// Drives the gallery add/edit photo form: shows a live preview of the picked
// image before upload, and closes the inline form without a round trip.
export default class extends Controller {
  static targets = ["input", "preview"]

  preview() {
    const file = this.inputTarget.files[0]
    if (!file) return

    if (this.previewTarget.dataset.objectUrl) {
      URL.revokeObjectURL(this.previewTarget.dataset.objectUrl)
    }

    const url = URL.createObjectURL(file)
    this.previewTarget.src = url
    this.previewTarget.dataset.objectUrl = url
  }

  closeForm(event) {
    event.preventDefault()
    const frame = this.element.closest("turbo-frame")
    if (frame) {
      frame.removeAttribute("complete")
      frame.innerHTML = ""
    } else {
      this.element.remove()
    }
  }
}
