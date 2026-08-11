// app/javascript/controllers/day_events_controller.js
// Shared "N more events" modal for a busy calendar day. Each day cell with
// overflow renders a <template> holding its extra events; clicking "+N more"
// clones that template's content into this shared modal instead of expanding
// in place, so busy days don't distort the grid.

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "title", "body"]

  connect() {
    this.onKeydown = this.onKeydown.bind(this)
  }

  show(event) {
    const trigger = event.currentTarget
    const template = document.getElementById(trigger.dataset.templateId)
    if (!template) return

    this.titleTarget.textContent = trigger.dataset.dayLabel
    this.bodyTarget.innerHTML = ""
    this.bodyTarget.appendChild(template.content.cloneNode(true))

    this.dialogTarget.classList.add("open")
    document.addEventListener("keydown", this.onKeydown)
  }

  close() {
    this.dialogTarget.classList.remove("open")
    document.removeEventListener("keydown", this.onKeydown)
  }

  closeBackground(event) {
    if (event.target === this.dialogTarget) this.close()
  }

  onKeydown(event) {
    if (event.key === "Escape") this.close()
  }
}
