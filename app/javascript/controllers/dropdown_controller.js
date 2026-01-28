import { Controller } from "@hotwired/stimulus"

// Reusable dropdown controller for menus
// Usage: data-controller="dropdown"
//        data-action="click->dropdown#toggle"
//        data-dropdown-target="menu"
export default class extends Controller {
  static targets = ["menu", "button", "mobileMenu"]

  connect() {
    this.isOpen = false
    this.isMobileOpen = false
  }

  toggle(event) {
    event.stopPropagation()
    this.isOpen = !this.isOpen
    this.updateMenu()
  }

  toggleMobile() {
    this.isMobileOpen = !this.isMobileOpen
    this.updateMobileMenu()
  }

  close(event) {
    // Don't close if clicking inside the menu or button
    if (this.hasMenuTarget && this.menuTarget.contains(event.target)) return
    if (this.hasButtonTarget && this.buttonTarget.contains(event.target)) return

    this.isOpen = false
    this.updateMenu()
  }

  updateMenu() {
    if (!this.hasMenuTarget) return

    if (this.isOpen) {
      this.menuTarget.classList.remove("hidden")
      this.menuTarget.classList.add("animate-fade-in")
    } else {
      this.menuTarget.classList.add("hidden")
      this.menuTarget.classList.remove("animate-fade-in")
    }
  }

  updateMobileMenu() {
    if (!this.hasMobileMenuTarget) return

    if (this.isMobileOpen) {
      this.mobileMenuTarget.classList.remove("hidden")
    } else {
      this.mobileMenuTarget.classList.add("hidden")
    }
  }
}
