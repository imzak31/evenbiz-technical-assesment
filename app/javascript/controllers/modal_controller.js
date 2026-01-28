import { Controller } from "@hotwired/stimulus"

// Modal controller for dialogs and confirmations
// Usage: data-controller="modal"
//        data-action="click->modal#open"
//        data-modal-target="dialog"
export default class extends Controller {
  static targets = ["dialog", "backdrop"]

  connect() {
    this.isOpen = false
  }

  open(event) {
    event.preventDefault()
    this.isOpen = true
    this.update()
    document.body.classList.add("overflow-hidden")
  }

  close(event) {
    if (event) event.preventDefault()
    this.isOpen = false
    this.update()
    document.body.classList.remove("overflow-hidden")
  }

  closeOnBackdrop(event) {
    if (event.target === this.backdropTarget) {
      this.close()
    }
  }

  closeOnEscape(event) {
    if (event.key === "Escape" && this.isOpen) {
      this.close()
    }
  }

  update() {
    if (this.hasDialogTarget) {
      this.dialogTarget.classList.toggle("hidden", !this.isOpen)
    }
    if (this.hasBackdropTarget) {
      this.backdropTarget.classList.toggle("hidden", !this.isOpen)
    }
  }
}
