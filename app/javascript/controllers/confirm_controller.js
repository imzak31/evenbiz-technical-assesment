import { Controller } from "@hotwired/stimulus"

// Custom confirmation dialog controller
// Replaces the default browser confirm with a styled modal
export default class extends Controller {
  static targets = ["dialog", "title", "message"]
  static values = {
    title: { type: String, default: "Confirm Action" },
    message: { type: String, default: "Are you sure?" }
  }

  connect() {
    // Store the form to submit after confirmation
    this.pendingForm = null
  }

  // Called when a delete button is clicked
  show(event) {
    event.preventDefault()
    
    // Find the form (button_to creates a form)
    const button = event.currentTarget
    this.pendingForm = button.closest("form")
    
    // Get custom title and message from data attributes
    const title = button.dataset.confirmTitle || this.titleValue
    const message = button.dataset.confirmMessage || this.messageValue
    
    // Update dialog content
    if (this.hasTitleTarget) this.titleTarget.textContent = title
    if (this.hasMessageTarget) this.messageTarget.textContent = message
    
    // Show dialog
    this.dialogTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
    
    // Focus the cancel button for accessibility
    this.dialogTarget.querySelector("[data-confirm-cancel]")?.focus()
  }

  confirm() {
    if (this.pendingForm) {
      // Submit the form
      this.pendingForm.requestSubmit()
    }
    this.close()
  }

  cancel() {
    this.close()
  }

  close() {
    this.dialogTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
    this.pendingForm = null
  }

  // Close on escape key
  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  // Close when clicking backdrop
  closeOnBackdrop(event) {
    if (event.target === event.currentTarget) {
      this.close()
    }
  }
}
