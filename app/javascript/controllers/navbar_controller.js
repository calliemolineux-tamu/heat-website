// app/javascript/controllers/navbar_controller.js

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "toggle"]

  connect() {
    this.closeOnOutsideClick = this.closeOnOutsideClick.bind(this)
    this.closeOnEscape = this.closeOnEscape.bind(this)
    this.close = this.close.bind(this)

    document.addEventListener("click", this.closeOnOutsideClick)
    document.addEventListener("keydown", this.closeOnEscape)
    document.addEventListener("turbo:before-visit", this.close)
    // Close after tapping a link in the mobile menu
    this.listTarget.addEventListener("click", this.close)
  }

  disconnect() {
    document.removeEventListener("click", this.closeOnOutsideClick)
    document.removeEventListener("keydown", this.closeOnEscape)
    document.removeEventListener("turbo:before-visit", this.close)
    this.listTarget.removeEventListener("click", this.close)
  }

  toggle(event) {
    event.stopPropagation()
    this.setOpen(!this.listTarget.classList.contains("is-active"))
  }

  close() {
    this.setOpen(false)
  }

  closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) this.close()
  }

  closeOnEscape(event) {
    if (event.key === "Escape") this.close()
  }

  setOpen(open) {
    this.listTarget.classList.toggle("is-active", open)
    if (this.hasToggleTarget) {
      this.toggleTarget.setAttribute("aria-expanded", open)
      this.toggleTarget.textContent = open ? "✕" : "☰"
    }
  }
}
