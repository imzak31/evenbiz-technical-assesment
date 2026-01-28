import { Controller } from "@hotwired/stimulus"

// Updates the album artist dropdown based on selected artists in the release form
export default class extends Controller {
  static targets = ["albumArtistSelect", "artistCheckbox"]

  connect() {
    this.updateAlbumArtistOptions()
  }

  // Called when artist checkboxes change
  artistChanged() {
    this.updateAlbumArtistOptions()
  }

  // Update the "Album Owner" dropdown based on selected artists
  updateAlbumArtistOptions() {
    if (!this.hasAlbumArtistSelectTarget) return

    const select = this.albumArtistSelectTarget
    const currentValue = select.value

    // Get all checked artist checkboxes
    const checkedArtists = this.artistCheckboxTargets.filter(cb => cb.checked)

    // Clear and rebuild options
    select.innerHTML = '<option value="">Select album owner...</option>'

    checkedArtists.forEach(cb => {
      const option = document.createElement("option")
      option.value = cb.value
      option.textContent = cb.dataset.artistName
      if (cb.value === currentValue) {
        option.selected = true
      }
      select.appendChild(option)
    })

    // If no artists selected, add a message
    if (checkedArtists.length === 0) {
      select.innerHTML = '<option value="">Select artists first...</option>'
    }
  }
}
