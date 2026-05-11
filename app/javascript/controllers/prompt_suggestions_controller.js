import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "thinking", "submit", "suggestion"]

  connect() {
    this.processing = false
  }

  submit(event) {
    if (this.processing) return

    const prompt = event.currentTarget.dataset.prompt
    if (!prompt || !this.hasInputTarget) return

    this.inputTarget.value = prompt
    this.inputTarget.form.requestSubmit()
  }

  lockSubmit(event) {
    if (this.processing) {
      event.preventDefault()
      event.stopImmediatePropagation()
      return
    }

    this.showThinking()
  }

  showThinking() {
    this.processing = true

    if (this.hasThinkingTarget) {
      this.thinkingTarget.classList.remove("hidden")
      this.thinkingTarget.classList.add("flex")
    }

    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = true
      this.submitTarget.classList.add("opacity-60")
    }

    this.suggestionTargets.forEach((suggestion) => {
      suggestion.disabled = true
      suggestion.classList.add("pointer-events-none", "opacity-50")
    })
  }

  hideThinking(event) {
    this.processing = false

    if (this.hasThinkingTarget) {
      this.thinkingTarget.classList.add("hidden")
      this.thinkingTarget.classList.remove("flex")
    }

    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = false
      this.submitTarget.classList.remove("opacity-60")
    }

    this.suggestionTargets.forEach((suggestion) => {
      suggestion.disabled = false
      suggestion.classList.remove("pointer-events-none", "opacity-50")
    })

    if (event.detail.success && this.hasInputTarget) {
      this.inputTarget.value = ""
    }
  }
}
