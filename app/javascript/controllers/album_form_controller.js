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
        console.error("Failed to fetch release")
        return
      }

      const release = await response.json()
      const artistIds = release.artists?.map(a => a.id) || []

      if (artistIds.length === 0) {
        // Release has no artists, show all
        this.showAllArtists()
        return
      }

      // Filter dropdown to only show artists associated with this release
      this.filterArtistOptions(artistIds)
    } catch (error) {
      console.error("Error fetching release artists:", error)
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

  updateHelperText(count) {
    if (!this.hasArtistContainerTarget) return

    let helper = this.artistContainerTarget.querySelector(".artist-helper")
    if (!helper) {
      helper = document.createElement("p")
      helper.className = "artist-helper mt-1 text-xs text-gray-500"
      this.artistContainerTarget.appendChild(helper)
    }

    if (count === null) {
      helper.textContent = "Select a release first to filter artists"
    } else if (count === 0) {
      helper.textContent = "This release has no associated artists"
    } else {
      helper.textContent = `Showing ${count} artist(s) associated with this release`
    }
  }
}
