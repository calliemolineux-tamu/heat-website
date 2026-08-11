// app/javascript/controllers/toggle_controller.js
// Generic show/hide: reveals its "content" target(s) while a checkbox is
// checked. Used by the event form's "Repeat this event" checkbox, but is
// intentionally generic so other forms can reuse it later.
//
// <div data-controller="toggle">
//   <input type="checkbox" data-action="toggle#update">
//   <div data-toggle-target="content" hidden>...</div>
// </div>

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]

  connect() {
    this.update()
  }

  update(event) {
    const checkbox = event ? event.target : this.element.querySelector('input[type="checkbox"]')
    const show = checkbox?.checked ?? false
    this.contentTargets.forEach((el) => { el.hidden = !show })
  }
}
