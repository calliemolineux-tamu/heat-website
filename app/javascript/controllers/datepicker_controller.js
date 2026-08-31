// app/javascript/controllers/datepicker_controller.js
// Wraps a plain text input in a flatpickr date+time picker themed to match the
// site. Rails still receives a plain "Y-m-d H:i" string it can parse into a
// datetime column; the altInput shows a friendlier display format.

import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

export default class extends Controller {
  connect() {
    this.picker = flatpickr(this.element, {
      enableTime: true,
      dateFormat: "Y-m-d H:i",
      altInput: true,
      altFormat: "F j, Y h:i K",
      time_24hr: false,
    })
  }

  disconnect() {
    this.picker?.destroy()
  }
}
