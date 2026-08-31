# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin 'application'
pin '@hotwired/turbo-rails', to: 'turbo.min.js', preload: true
pin '@hotwired/stimulus', to: 'stimulus.min.js', preload: true
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'
pin 'flatpickr', to: 'https://cdn.jsdelivr.net/npm/flatpickr@4.6.13/+esm'
pin_all_from 'app/javascript/controllers', under: 'controllers'
