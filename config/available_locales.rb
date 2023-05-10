# coding: utf-8
# frozen_string_literal: true

module Boatinn
  # Format: [name, identifier, language, region, fallback identifier]
  #
  # language format: ISO 639-1, two letters, lowercase
  # region format: ISO 3166, two letters, uppercase
  # fallbacks: should not include US English, which is the last default fallback for each language

  # List of locales that are completely or almost completely translated

  AVAILABLE_LOCALES = [
    { ident: 'en', name: 'English', language: 'en', region: 'US', fallback: nil }, # English (United States)
    # { ident: 'de', name: 'Deutsch', language: 'de', region: 'DE', fallback: nil }, # German (Germany)
    # { ident: 'ru', name: 'Pусский', language: 'ru', region: 'RU', fallback: nil }, # Russian (Russia)
    # { ident: 'fr', name: 'Français', language: 'fr', region: 'FR', fallback: nil }, # French (France)
    { ident: 'es', name: 'Español', language: 'es', region: 'ES', fallback: nil }, # Spanish (Spain)
    # { ident: 'it', name: 'Italiano', language: 'it', region: 'IT', fallback: nil }, # Italian (Italy)
  ].freeze

  # Short format

  AVAILABLE_LOCALES_SHORT_FORMAT = AVAILABLE_LOCALES.map { |l| l[:ident] }

end