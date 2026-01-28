import { Controller } from "@hotwired/stimulus"

// Handles dynamic filtering of artists based on selected release
// Connects to data-controller="album-form"
export default class extends Controller {
  static targets = ["release", "artist", "artistContainer"]

  connect() {
    // If a release is already selected, filter artists
    if (this.hasReleaseTarget && this.releaseTarget.value) {
      this.filterArtists()
    }
  }

  releaseChanged() {
    this.filterArtists()
  }

  async filterArtists() {
    const releaseId = this.releaseTarget.value

    if (!releaseId) {
      // No release selected, show all artists
      this.showAllArtists()
      return
    }

    try {
      const response = await fetch(`/releases/${releaseId}.json`)
      if (!response.ok) {
        this.showError("Failed to load artists for this release")
        return
      }

      const release = await response.json()
      const artistIds = release.artists?.map(a => a.id) || []

      if (artistIds.length === 0) {
        // Release has no artists, show all with warning
        this.showAllArtists()
        this.updateHelperText(0)
        return
      }

      // Filter dropdown to only show artists associated with this release
      this.filterArtistOptions(artistIds)
    } catch (error) {
      console.error("Error fetching release artists:", error)
      this.showError("Failed to load artists. Please refresh and try again.")
    }
  }

  filterArtistOptions(artistIds) {
    const select = this.artistTarget
    const currentValue = select.value

    Array.from(select.options).forEach(option => {
      if (option.value === "" || artistIds.includes(parseInt(option.value))) {
        option.hidden = false
        option.disabled = false
      } else {
        option.hidden = true
        option.disabled = true
      }
    })

    // If current selection is not in the filtered list, reset
    if (currentValue && !artistIds.includes(parseInt(currentValue))) {
      select.value = ""
    }

    // Update helper text
    this.updateHelperText(artistIds.length)
  }

  showAllArtists() {
    const select = this.artistTarget
    Array.from(select.options).forEach(option => {
      option.hidden = false
      option.disabled = false
    })
    this.updateHelperText(null)
  }

  showError(message) {
    this.showAllArtists()
    const helper = this.getHelperElement()
    if (helper) {
      helper.textContent = message
      helper.classList.add("text-red-500")
      helper.classList.remove("text-gray-500")
    }
  }

  getHelperElement() {
    if (!this.hasArtistContainerTarget) return null
    return this.artistContainerTarget.querySelector(".artist-helper")
  }

  updateHelperText(count) {
    const helper = this.getHelperElement()
    if (!helper) return

    helper.classList.remove("text-red-500")
    helper.classList.add("text-gray-500")

    if (count === null) {
      helper.textContent = "Select a release first to filter artists"
    } else if (count === 0) {
      helper.textContent = "This release has no associated artists"
    } else {
      helper.textContent = `Showing ${count} artist(s) associated with this release`
    }
  }
}
