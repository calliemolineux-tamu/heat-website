import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slide", "description"]
  static values = { descriptions: Array }

  initialize() {
    this.currentIndex = 0
  }

  connect() {
    this.showCurrentSlide()

    // Swipe left/right on touchscreens
    this.onTouchStart = (event) => { this.touchStartX = event.changedTouches[0].clientX }
    this.onTouchEnd = (event) => {
      const deltaX = event.changedTouches[0].clientX - this.touchStartX
      if (Math.abs(deltaX) < 40) return
      deltaX < 0 ? this.next() : this.previous()
    }
    this.element.addEventListener("touchstart", this.onTouchStart, { passive: true })
    this.element.addEventListener("touchend", this.onTouchEnd, { passive: true })
  }

  disconnect() {
    this.element.removeEventListener("touchstart", this.onTouchStart)
    this.element.removeEventListener("touchend", this.onTouchEnd)
  }

  next() {
    this.currentIndex = (this.currentIndex + 1) % this.slideTargets.length
    this.showCurrentSlide()
  }

  previous() {
    this.currentIndex = (this.currentIndex - 1 + this.slideTargets.length) % this.slideTargets.length
    this.showCurrentSlide()
  }

  showCurrentSlide() {
    // Update slides
    this.slideTargets.forEach((element, index) => {
      element.classList.toggle("hidden", index !== this.currentIndex)
    })

    // Update description
    this.descriptionTarget.textContent = this.descriptionsValue[this.currentIndex]
  }
}
