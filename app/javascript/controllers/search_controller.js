import { Controller } from "@hotwired/stimulus"

// Provides live debounced search functionality
// Auto-submits after typing 3+ characters or when clearing
// Maintains focus after Turbo page updates
export default class extends Controller {
  static targets = ["input"]
  static values = { 
    delay: { type: Number, default: 300 },
    minChars: { type: Number, default: 3 }
  }

  connect() {
    this.timeout = null
    this.cursorPosition = 0
    
    // Listen for Turbo frame load to refocus
    document.addEventListener("turbo:frame-render", this.refocus)
    document.addEventListener("turbo:render", this.refocus)
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
    document.removeEventListener("turbo:frame-render", this.refocus)
    document.removeEventListener("turbo:render", this.refocus)
  }

  refocus = () => {
    // Find the search input and refocus it
    requestAnimationFrame(() => {
      const input = document.querySelector('input[name="q"]')
      if (input) {
        input.focus()
        // Restore cursor to end of input
        const len = input.value.length
        input.setSelectionRange(len, len)
      }
    })
  }

  debounce(event) {
    const query = event.target.value.trim()
    
    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    // Submit if:
    // - Query has 3+ characters (search)
    // - Query is empty (show all results)
    if (query.length >= this.minCharsValue || query.length === 0) {
      this.timeout = setTimeout(() => {
        this.element.requestSubmit()
      }, this.delayValue)
    }
  }

  // Allow immediate submit on Enter key
  submit(event) {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
    // Let the form submit naturally
  }
}
