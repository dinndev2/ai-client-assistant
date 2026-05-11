import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.observer = new MutationObserver((mutations) => {
      if (mutations.some((mutation) => mutation.addedNodes.length > 0)) {
        this.scrollToLatest()
      }
    })

    this.observer.observe(this.element, { childList: true })
  }

  disconnect() {
    this.observer?.disconnect()
  }

  scrollToLatest() {
    requestAnimationFrame(() => {
      this.element.lastElementChild?.scrollIntoView({
        behavior: "smooth",
        block: "end"
      })
    })
  }
}
