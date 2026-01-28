import { Controller } from "@hotwired/stimulus"

// Form enhancements: validation feedback, submit state
// Usage: data-controller="form"
export default class extends Controller {
  static targets = ["submit", "field"]
  static values = {
    submitting: { type: String, default: "Saving..." }
  }

  connect() {
    this.originalText = this.hasSubmitTarget ? this.submitTarget.value || this.submitTarget.textContent : ""
  }

  // Called on form submit
  submit() {
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = true
      if (this.submitTarget.tagName === "INPUT") {
        this.submitTarget.value = this.submittingValue
      } else {
        this.submitTarget.textContent = this.submittingValue
      }
    }
  }

  // Re-enable on turbo:submit-end
  reset() {
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = false
      if (this.submitTarget.tagName === "INPUT") {
        this.submitTarget.value = this.originalText
      } else {
        this.submitTarget.textContent = this.originalText
      }
    }
  }

  // Clear field errors on input
  clearError(event) {
    const field = event.target
    const wrapper = field.closest("[data-form-field]")
    if (wrapper) {
      const errorEl = wrapper.querySelector("[data-form-error]")
      if (errorEl) errorEl.remove()
      field.classList.remove("border-red-300", "focus:border-red-500", "focus:ring-red-500")
      field.classList.add("border-gray-300", "focus:border-indigo-500", "focus:ring-indigo-500")
    }
  }
}
