import { Controller } from "@hotwired/stimulus"

// Client-side, single-select filter for the "Upcoming Events" list. Shows/hides
// .event cards (read via their data-committee attribute) based on which tab is
// active; clicking the active tab again (or "All") resets. Cards are queried
// live from the DOM on every click rather than cached as targets, since
// #event_list's contents are replaced wholesale by a Turbo Stream after an
// inline event create.
export default class extends Controller {
  static targets = ["tab"]

  filter(event) {
    const clicked = event.currentTarget.dataset.committee
    const activeTab = this.tabTargets.find((tab) => tab.classList.contains("is-active"))
    const alreadyActive = activeTab?.dataset.committee === clicked
    const nextCommittee = alreadyActive ? "all" : clicked

    this.tabTargets.forEach((tab) => {
      tab.classList.toggle("is-active", tab.dataset.committee === nextCommittee)
    })

    this.element.querySelectorAll(".event").forEach((card) => {
      card.hidden = nextCommittee !== "all" && card.dataset.committee !== nextCommittee
    })
  }
}
