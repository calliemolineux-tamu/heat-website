// app/javascript/controllers/modal_controller.js
// Reusable overlay/modal shell (generalized from the photo gallery's
// fullscreen_controller pattern). Toggles an "open" class on the dialog
// target; closes on backdrop click or Escape.

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog"]

  connect() {
    this.onKeydown = this.onKeydown.bind(this)
  }

  open() {
    this.dialogTarget.classList.add("open")
    document.addEventListener("keydown", this.onKeydown)
  }

  close() {
    this.dialogTarget.classList.remove("open")
    document.removeEventListener("keydown", this.onKeydown)
  }

  // Bind with data-action="click->modal#closeBackground" on the dialog element
  // itself, so clicks on the backdrop (not the modal content) close it.
  closeBackground(event) {
    if (event.target === this.dialogTarget) this.close()
  }

  onKeydown(event) {
    if (event.key === "Escape") this.close()
  }
}
