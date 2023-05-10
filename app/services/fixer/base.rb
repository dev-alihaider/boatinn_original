# frozen_string_literal: true

module Fixer
  class Base # :nodoc:
    attr_reader :response
    attr_reader :error
    attr_accessor :base

    def initialize(base = 'EUR')
      @base = base
    end

    def fetch_rates
      process_response
    rescue StandardError => e
      @error = e.message
    ensure
      @response
    end

    private

    def process_response
      response = RestClient.get(url)

      if response.code == 200
        body = JSON.parse(response.body)

        body['success'] ? @response = body : @error = body['error']
      else
        @error = response.body
      end
    end

    def url
      "http://data.fixer.io/api/latest?access_key=#{access_key}&format=1&"\
        "base=#{@base}"
    end

    def access_key
      ENV['FIXER_ACCESS_KEY']
    end
  end
end
