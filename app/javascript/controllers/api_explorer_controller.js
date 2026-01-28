import { Controller } from "@hotwired/stimulus"

// API Explorer Controller
// Provides an interactive interface for testing the releases API
export default class extends Controller {
  static targets = [
    "endpoint",
    "page",
    "limit",
    "past",
    "search",
    "requestUrl",
    "curlCommand",
    "response",
    "status",
    "duration",
    "sendButton",
    "recordCount",
    "paginationInfo",
    "metaPage",
    "metaTotalPages",
    "metaTotalCount",
    "metaPerPage",
    "prevPageBtn",
    "nextPageBtn",
    "tokenFull",
    "copyTokenBtn",
    "copyCurlBtn",
    "copyResponseBtn"
  ]

  static values = {
    token: String,
    baseUrl: String
  }

  connect() {
    this.updatePreview()
    this.lastResponse = null
  }

  // Update the request preview when any parameter changes
  updatePreview() {
    const url = this.buildFullUrl()
    const curl = this.buildCurlCommand(url)

    this.requestUrlTarget.textContent = url
    this.curlCommandTarget.textContent = curl
  }

  // Build the full API URL with query parameters
  buildFullUrl() {
    const endpoint = this.endpointTarget.value
    const params = this.buildQueryParams()
    const queryString = new URLSearchParams(params).toString()

    let url = `${this.baseUrlValue}/api${endpoint}`
    if (queryString) {
      url += `?${queryString}`
    }
    return url
  }

  // Build query parameters object
  buildQueryParams() {
    const params = {}

    const page = this.pageTarget.value
    if (page && page !== "1") {
      params.page = page
    }

    const limit = this.limitTarget.value
    if (limit && limit !== "10") {
      params.limit = limit
    }

    const past = this.pastTarget.value
    if (past !== "") {
      params.past = past
    }

    const search = this.searchTarget.value.trim()
    if (search) {
      params.search = search
    }

    return params
  }

  // Build curl command for copying
  buildCurlCommand(url) {
    return `curl -X GET "${url}" \\
  -H "Authorization: Bearer ${this.tokenValue}" \\
  -H "Accept: application/json"`
  }

  // Fallback copy method for HTTP contexts
  copyToClipboard(text) {
    // Try modern clipboard API first
    if (navigator.clipboard && window.isSecureContext) {
      return navigator.clipboard.writeText(text)
    }
    
    // Fallback for HTTP or older browsers
    return new Promise((resolve, reject) => {
      const textArea = document.createElement("textarea")
      textArea.value = text
      textArea.style.position = "fixed"
      textArea.style.left = "-999999px"
      textArea.style.top = "-999999px"
      document.body.appendChild(textArea)
      textArea.focus()
      textArea.select()
      
      try {
        const successful = document.execCommand('copy')
        document.body.removeChild(textArea)
        if (successful) {
          resolve()
        } else {
          reject(new Error('Copy command failed'))
        }
      } catch (err) {
        document.body.removeChild(textArea)
        reject(err)
      }
    })
  }

  // Copy API token to clipboard
  copyToken(event) {
    event.preventDefault()
    const token = this.tokenFullTarget.value
    this.copyToClipboard(token)
      .then(() => this.showButtonSuccess(this.copyTokenBtnTarget, "Copied!"))
      .catch(() => this.showButtonError(this.copyTokenBtnTarget, "Failed"))
  }

  // Copy curl command to clipboard
  copyCurl(event) {
    event.preventDefault()
    const curl = this.curlCommandTarget.textContent
    this.copyToClipboard(curl)
      .then(() => this.showButtonSuccess(this.copyCurlBtnTarget, "Copied!"))
      .catch(() => this.showButtonError(this.copyCurlBtnTarget, "Failed"))
  }

  // Copy response JSON to clipboard
  copyResponse(event) {
    event.preventDefault()
    if (!this.lastResponse) {
      this.showButtonError(this.copyResponseBtnTarget, "No data")
      return
    }
    
    const json = JSON.stringify(this.lastResponse, null, 2)
    this.copyToClipboard(json)
      .then(() => this.showButtonSuccess(this.copyResponseBtnTarget, "Copied!"))
      .catch(() => this.showButtonError(this.copyResponseBtnTarget, "Failed"))
  }

  // Show success state on a copy button
  showButtonSuccess(btn, message) {
    const originalHTML = btn.innerHTML
    btn.innerHTML = `
      <svg class="h-4 w-4 mr-1 text-green-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
      </svg>
      <span class="text-green-600">${message}</span>
    `
    btn.classList.add("bg-green-50")
    setTimeout(() => {
      btn.innerHTML = originalHTML
      btn.classList.remove("bg-green-50")
    }, 1500)
  }

  // Show error state on a copy button
  showButtonError(btn, message) {
    const originalHTML = btn.innerHTML
    btn.innerHTML = `
      <svg class="h-4 w-4 mr-1 text-red-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
      </svg>
      <span class="text-red-600">${message}</span>
    `
    btn.classList.add("bg-red-50")
    setTimeout(() => {
      btn.innerHTML = originalHTML
      btn.classList.remove("bg-red-50")
    }, 1500)
  }

  // Send the API request
  async sendRequest() {
    this.sendButtonTarget.disabled = true
    this.sendButtonTarget.innerHTML = `
      <svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
      </svg>
      Sending...
    `

    try {
      const params = new URLSearchParams({
        endpoint: this.endpointTarget.value,
        ...this.buildQueryParams()
      })

      const response = await fetch("/api_explorer/execute", {
        method: "POST",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        },
        body: params
      })

      const result = await response.json()
      this.displayResponse(result)
    } catch (error) {
      this.displayError(error)
    } finally {
      this.sendButtonTarget.disabled = false
      this.sendButtonTarget.innerHTML = `
        <svg class="-ml-0.5 mr-1.5 h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" />
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        Send Request
      `
    }
  }

  displayResponse(result) {
    // Store for copy functionality
    this.lastResponse = result.body

    // Status
    const statusClass = result.status >= 200 && result.status < 300 
      ? "bg-green-100 text-green-800" 
      : "bg-red-100 text-red-800"
    this.statusTarget.className = `inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${statusClass}`
    this.statusTarget.textContent = `${result.status} ${this.getStatusText(result.status)}`

    // Duration
    this.durationTarget.textContent = `${result.duration}ms`

    // Record count
    const data = result.body?.data
    if (Array.isArray(data)) {
      this.recordCountTarget.textContent = data.length
    } else {
      this.recordCountTarget.textContent = "—"
    }

    // Pagination meta
    const meta = result.body?.meta
    if (meta) {
      this.paginationInfoTarget.classList.remove("hidden")
      this.metaPageTarget.textContent = meta.current_page || "-"
      this.metaTotalPagesTarget.textContent = meta.total_pages || "-"
      this.metaTotalCountTarget.textContent = meta.total_count || "-"
      this.metaPerPageTarget.textContent = meta.per_page || "-"
      
      // Enable/disable pagination buttons
      this.prevPageBtnTarget.disabled = !meta.current_page || meta.current_page <= 1
      this.nextPageBtnTarget.disabled = !meta.current_page || meta.current_page >= meta.total_pages
    } else {
      this.paginationInfoTarget.classList.add("hidden")
    }

    // Response body with syntax highlighting
    const formatted = this.syntaxHighlight(result.body)
    this.responseTarget.innerHTML = formatted
  }

  // Syntax highlighting for JSON
  syntaxHighlight(json) {
    const str = JSON.stringify(json, null, 2)
    return str.replace(/("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)/g, (match) => {
      let cls = 'text-amber-400' // number
      if (/^"/.test(match)) {
        if (/:$/.test(match)) {
          cls = 'text-sky-400' // key
        } else {
          cls = 'text-emerald-400' // string
        }
      } else if (/true|false/.test(match)) {
        cls = 'text-purple-400' // boolean
      } else if (/null/.test(match)) {
        cls = 'text-gray-500' // null
      }
      return `<span class="${cls}">${match}</span>`
    })
  }

  displayError(error) {
    this.lastResponse = { error: error.message }
    this.statusTarget.className = "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800"
    this.statusTarget.textContent = "Error"
    this.durationTarget.textContent = "—"
    this.recordCountTarget.textContent = "—"
    this.paginationInfoTarget.classList.add("hidden")
    this.responseTarget.innerHTML = this.syntaxHighlight({ error: error.message })
  }

  // Navigate to previous page and auto-send
  goToPrevPage() {
    const current = parseInt(this.pageTarget.value) || 1
    if (current > 1) {
      this.pageTarget.value = current - 1
      this.updatePreview()
      this.sendRequest()
    }
  }

  // Navigate to next page and auto-send
  goToNextPage() {
    const current = parseInt(this.pageTarget.value) || 1
    this.pageTarget.value = current + 1
    this.updatePreview()
    this.sendRequest()
  }

  getStatusText(status) {
    const statusTexts = {
      200: "OK",
      201: "Created",
      400: "Bad Request",
      401: "Unauthorized",
      403: "Forbidden",
      404: "Not Found",
      422: "Unprocessable Entity",
      500: "Internal Server Error"
    }
    return statusTexts[status] || ""
  }

  // Reset all filters to defaults
  resetFilters() {
    this.pageTarget.value = "1"
    this.limitTarget.value = "10"
    this.pastTarget.value = ""
    this.searchTarget.value = ""
    this.updatePreview()
  }

  // Pagination helpers
  previousPage() {
    const current = parseInt(this.pageTarget.value) || 1
    if (current > 1) {
      this.pageTarget.value = current - 1
      this.updatePreview()
    }
  }

  nextPage() {
    const current = parseInt(this.pageTarget.value) || 1
    this.pageTarget.value = current + 1
    this.updatePreview()
  }
}
