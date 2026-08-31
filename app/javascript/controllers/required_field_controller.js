// app/javascript/controllers/required_field_controller.js
// Blocks submission of a form while any [required] field is empty and shows
// an inline "<Field label> is missing" message under it, instead of letting
// a blank-required-field submission round-trip to the server. Uses an inline
// message rather than the browser's native validation bubble because some
// required fields (e.g. the flatpickr-enhanced start time) hide their real
// input via altInput, and native bubbles anchor unreliably to hidden inputs.
// Attach with data-controller="required-field" on the <form>.

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.setAttribute("novalidate", "novalidate") // we own validation UI, not the browser
    this.element.addEventListener("submit", this.validate.bind(this))
  }

  validate(event) {
    let firstInvalid = null

    this.requiredFields().forEach((field) => {
      if (field.value.trim()) {
        this.clearError(field)
        return
      }

      firstInvalid ||= field
      this.showError(field)
    })

    if (firstInvalid) {
      event.preventDefault()
      firstInvalid.focus()
    }
  }

  showError(field) {
    field.classList.add("form-control--invalid")

    let errorEl = this.errorElementFor(field)
    if (!errorEl) {
      errorEl = document.createElement("p")
      errorEl.className = "form-error"
      errorEl.dataset.requiredFieldErrorFor = field.id
      field.insertAdjacentElement("afterend", errorEl)
      field.addEventListener("input", () => this.clearError(field), { once: true })
    }
    errorEl.textContent = `${this.labelFor(field)} is missing`
  }

  clearError(field) {
    field.classList.remove("form-control--invalid")
    this.errorElementFor(field)?.remove()
  }

  errorElementFor(field) {
    return this.element.querySelector(`[data-required-field-error-for="${field.id}"]`)
  }

  labelFor(field) {
    return field.labels?.[0]?.textContent?.trim() || field.name
  }

  requiredFields() {
    return Array.from(this.element.querySelectorAll("[required]"))
  }
}
