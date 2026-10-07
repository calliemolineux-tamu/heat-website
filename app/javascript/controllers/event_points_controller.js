import { Controller } from "@hotwired/stimulus"

// Live-updates the Points field as the admin sets/changes the event's start
// time, end time, or committee - mirroring Event#set_default_points in Ruby
// (general committee always defaults to 1; otherwise 1 point per hour,
// rounded to the nearest hour, falling back to 1 when either time is blank).
// Stops auto-updating only once the admin types into the Points field
// directly (not merely because it already shows a value - on the edit page
// it's pre-filled with the event's saved points, which should still update
// live when a time/committee is changed), and resumes if they clear it back
// to blank.
export default class extends Controller {
  static targets = ["startTime", "endTime", "committee", "points"]

  connect() {
    this.manuallySet = false
  }

  markManual() {
    this.manuallySet = this.pointsTarget.value !== ""
  }

  recalculate() {
    if (this.manuallySet) return

    this.pointsTarget.value = this.calculatePoints()
  }

  calculatePoints() {
    if (this.committeeTarget.value === "general") return 1

    const start = this.parseDateTime(this.startTimeTarget.value)
    const end = this.parseDateTime(this.endTimeTarget.value)
    if (!start || !end) return 1

    const hours = (end - start) / (1000 * 60 * 60)
    return Math.max(Math.round(hours), 1)
  }

  parseDateTime(value) {
    if (!value) return null

    const parsed = new Date(value.replace(" ", "T"))
    return Number.isNaN(parsed.getTime()) ? null : parsed
  }
}
