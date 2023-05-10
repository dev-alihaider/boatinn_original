# frozen_string_literal: true

module Api
  # Super controller for REST JSON API.
  #
  # Only 3 API responses are possible:
  #
  # Success
  #   1. The request was successful:
  #     - 200 OK
  #     - 201 Created
  #     - 204 No Content
  #     - 304 Not Modified
  #
  # Error
  #   2. Client: the wrong data was sent to the input:
  #     - 400 Bad Request
  #     - 403 Forbidden
  #     - 404 Not Found
  #     - 422 Unprocessable Entity
  #
  #   3. Server: an error occurred while processing the data:
  #     - 500 Internal Server Error
  class GenericController < ApplicationController
    respond_to :json

    rescue_from(StandardError) { |e| send_error(e, :internal_server_error) }
    rescue_from(ActiveRecord::RecordNotFound) { |e| send_error(e, :not_found) }
    rescue_from(ActiveRecord::RecordInvalid,
                ActiveModel::ValidationError,
                ActiveModel::UnknownAttributeError,
                ArgumentError) { |e| send_error(e, :bad_request) }

    def json_response(object, status = :ok)
      render json: object, status: status
    end

    private

    def send_error(error, status)
      json_response({ error: error.inspect, message: error.message },
                    status(status))
    end

    def status(code)
      params[:suppress_response_codes].present? ? :ok : code
    end
  end
end
