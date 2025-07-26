// app/javascript/controllers/game_controller.js
// Demonstrates modern Rails JavaScript patterns with Stimulus
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { autoRefresh: Number }
  static targets = [ "healthBar", "manaBar", "location", "inventory" ]

  connect() {
    console.log("Game controller connected")
    this.startAutoRefresh()
    this.setupKeyboardShortcuts()
  }

  disconnect() {
    this.stopAutoRefresh()
    this.removeKeyboardShortcuts()
  }

  // Auto-refresh game state for real-time updates
  startAutoRefresh() {
    if (this.autoRefreshValue > 0) {
      this.refreshInterval = setInterval(() => {
        this.refreshGameState()
      }, this.autoRefreshValue)
    }
  }

  stopAutoRefresh() {
    if (this.refreshInterval) {
      clearInterval(this.refreshInterval)
    }
  }

  refreshGameState() {
    // Use Turbo to refresh specific parts of the page
    fetch(window.location.href, {
      headers: {
        "Accept": "text/vnd.turbo-stream.html"
      }
    })
    .then(response => response.text())
    .then(html => {
      // Process turbo stream response
      Turbo.renderStreamMessage(html)
    })
    .catch(error => {
      console.warn("Failed to refresh game state:", error)
    })
  }

  // Keyboard shortcuts for common actions
  setupKeyboardShortcuts() {
    this.keyboardHandler = this.handleKeyboard.bind(this)
    document.addEventListener('keydown', this.keyboardHandler)
  }

  removeKeyboardShortcuts() {
    if (this.keyboardHandler) {
      document.removeEventListener('keydown', this.keyboardHandler)
    }
  }

  handleKeyboard(event) {
    // Only handle shortcuts when not typing in inputs
    if (event.target.tagName === 'INPUT' || event.target.tagName === 'TEXTAREA') {
      return
    }

    switch(event.key.toLowerCase()) {
      case 'n':
        this.move('north')
        break
      case 's':
        this.move('south')
        break
      case 'e':
        this.move('east')
        break
      case 'w':
        this.move('west')
        break
      case 'i':
        this.openInventory()
        break
      case 'r':
        this.rest()
        break
      case 'c':
        this.combat()
        break
    }
  }

  // Movement actions
  move(direction) {
    const form = document.createElement('form')
    form.method = 'POST'
    form.action = '/game/move'
    
    // CSRF token
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content
    form.innerHTML = `
      <input type="hidden" name="authenticity_token" value="${csrfToken}">
      <input type="hidden" name="_method" value="PATCH">
      <input type="hidden" name="direction" value="${direction}">
    `
    
    document.body.appendChild(form)
    form.submit()
  }

  openInventory() {
    window.location.href = '/inventory'
  }

  rest() {
    if (confirm('Rest and restore health/mana?')) {
      this.submitAction('/game/rest')
    }
  }

  combat() {
    if (confirm('Look for combat?')) {
      this.submitAction('/game/combat')
    }
  }

  submitAction(path) {
    const form = document.createElement('form')
    form.method = 'POST'
    form.action = path
    
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content
    form.innerHTML = `
      <input type="hidden" name="authenticity_token" value="${csrfToken}">
      <input type="hidden" name="_method" value="PATCH">
    `
    
    document.body.appendChild(form)
    form.submit()
  }

  // Update UI elements dynamically
  updateHealthBar(health, maxHealth) {
    if (this.hasHealthBarTarget) {
      const percentage = (health / maxHealth) * 100
      this.healthBarTarget.style.width = `${percentage}%`
      this.healthBarTarget.textContent = `${health}/${maxHealth}`
    }
  }

  updateManaBar(mana, maxMana) {
    if (this.hasManaBarTarget) {
      const percentage = (mana / maxMana) * 100
      this.manaBarTarget.style.width = `${percentage}%`
      this.manaBarTarget.textContent = `${mana}/${maxMana}`
    }
  }
}