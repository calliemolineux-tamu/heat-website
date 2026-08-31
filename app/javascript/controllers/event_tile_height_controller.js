import { Controller } from "@hotwired/stimulus"

// Keeps the "Upcoming Events" tile's height matched to the calendar's
// rendered height on desktop. A plain CSS align-items: stretch was tried
// first, but it doesn't reliably cap the tile's height: .event__container
// is itself a flex container, so its own auto min-height (driven by its
// content - the event list) can override the stretched value and let it
// grow to fit every event instead of stopping at the calendar's height.
// A ResizeObserver sidesteps that entirely by directly measuring and
// applying a real height, and re-fires whenever the calendar's rendered
// size changes for any reason - window resize, switching months, or the
// calendar being swapped via Turbo Stream after an inline event create.
export default class extends Controller {
  static targets = ["calendar", "tile"]

  connect() {
    this.desktopQuery = window.matchMedia("(min-width: 70rem)")
    this.handleQueryChange = this.sync.bind(this)
    this.desktopQuery.addEventListener("change", this.handleQueryChange)

    this.resizeObserver = new ResizeObserver(() => this.sync())
    if (this.hasCalendarTarget) this.resizeObserver.observe(this.calendarTarget)
  }

  disconnect() {
    this.resizeObserver?.disconnect()
    this.desktopQuery?.removeEventListener("change", this.handleQueryChange)
  }

  sync() {
    if (!this.hasCalendarTarget || !this.hasTileTarget) return

    // Below the desktop breakpoint .events stacks into a column and the
    // tile keeps its own compact fixed height from CSS (_event.scss) -
    // clear any inline height so that rule regains control.
    if (!this.desktopQuery.matches) {
      this.tileTarget.style.height = ""
      return
    }

    this.tileTarget.style.height = `${this.calendarTarget.offsetHeight}px`
  }
}
